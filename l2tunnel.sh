#!/bin/bash
set -euo pipefail

# ============================================
# L2 Tunnel Installer with Advanced Menu
# Version 2.1 - Custom passwords via panel
# ============================================

RED='\033[0;31m'; GREEN='\033[0;32m'; YELLOW='\033[1;33m'; BLUE='\033[0;34m'; NC='\033[0m'
info() { echo -e "${GREEN}[INFO]${NC} $1"; }
warn() { echo -e "${YELLOW}[WARN]${NC} $1"; }
err()  { echo -e "${RED}[ERROR]${NC} $1"; exit 1; }

# Global variables
METHOD=""
ROLE=""
WATERWALL_DIR="/etc/waterwall"
RATHOLE_DIR="/etc/rathole"
XRAY_CONFIG="/usr/local/etc/xray/config.json"
BIN_DIR="/usr/local/bin"
RATHOLE_PORT=443
DOMAIN=""
KHAREJ_IP=""
CDN_PASS=""
HD_PASS=""
RL_PASS=""
RATHOLE_TOKEN=""

# Ensure whiptail is installed
if ! command -v whiptail &> /dev/null; then
    echo "Installing whiptail..."
    apt update && apt install -y whiptail
fi

# ==================== UTILITY FUNCTIONS ====================

install_pkgs() {
    info "Updating packages..."
    apt update && apt upgrade -y
    apt install -y wget unzip openssl jq curl socat
}

download_waterwall() {
    if [ -f "$BIN_DIR/WaterWall" ]; then
        info "WaterWall already installed."
    else
        info "Downloading WaterWall..."
        cd /tmp
        wget -q https://github.com/radkesvat/WaterWall/releases/download/v1.18/WaterWall-linux-64.zip
        unzip -o WaterWall-linux-64.zip -d waterwall_tmp
        mv waterwall_tmp/WaterWall "$BIN_DIR/"
        chmod +x "$BIN_DIR/WaterWall"
        rm -rf waterwall_tmp WaterWall-linux-64.zip
        info "WaterWall installed."
    fi
}

download_rathole() {
    if [ -f "$BIN_DIR/rathole" ]; then
        info "Rathole already installed."
    else
        info "Downloading Rathole..."
        cd /tmp
        wget -q https://github.com/rapiz1/rathole/releases/download/v0.5.0/rathole-x86_64-unknown-linux-gnu.zip
        unzip -o rathole-x86_64-unknown-linux-gnu.zip -d rathole_tmp
        mv rathole_tmp/rathole "$BIN_DIR/"
        chmod +x "$BIN_DIR/rathole"
        rm -rf rathole_tmp rathole-x86_64-unknown-linux-gnu.zip
        info "Rathole installed."
    fi
}

install_xray() {
    if [ -f "$BIN_DIR/xray" ]; then
        info "Xray already installed."
    else
        info "Installing Xray..."
        bash -c "$(curl -L https://github.com/XTLS/Xray-install/raw/main/install-release.sh)" @ install
        info "Xray installed."
    fi
}

get_letsencrypt_cert() {
    local domain=$1
    if [ -f "/etc/letsencrypt/live/$domain/fullchain.pem" ]; then
        info "Let's Encrypt certificate already exists for $domain"
        return
    fi
    info "Obtaining Let's Encrypt certificate for $domain..."
    apt install -y certbot
    systemctl stop nginx apache2 2>/dev/null || true
    certbot certonly --standalone --non-interactive --agree-tos --email admin@$domain -d $domain
    if [ $? -eq 0 ]; then
        ln -sf "/etc/letsencrypt/live/$domain/fullchain.pem" /etc/ssl/certs/fullchain.pem
        ln -sf "/etc/letsencrypt/live/$domain/privkey.pem" /etc/ssl/private/privkey.pem
        info "Certificate obtained and linked."
    else
        warn "Let's Encrypt failed, using self-signed (CDN may reject)."
        openssl req -x509 -newkey rsa:4096 -keyout /etc/ssl/private/privkey.pem -out /etc/ssl/certs/fullchain.pem -days 3650 -nodes -subj "/CN=$domain"
    fi
}

create_service() {
    local name=$1
    local exec_cmd=$2
    cat > "/etc/systemd/system/${name}.service" <<EOF
[Unit]
Description=${name}
After=network.target
[Service]
Type=simple
ExecStart=${exec_cmd}
Restart=always
RestartSec=5
[Install]
WantedBy=multi-user.target
EOF
    systemctl daemon-reload
    systemctl enable "$name"
    systemctl start "$name"
    info "Service ${name} created."
}

stop_disable_service() {
    local name=$1
    systemctl stop "$name" 2>/dev/null || true
    systemctl disable "$name" 2>/dev/null || true
    rm -f "/etc/systemd/system/${name}.service"
    systemctl daemon-reload
}

# ==================== CONFIGURATION METHODS ====================

config_method1_rathole() {
    info "Configuring Method 1: Rathole + WaterWall (TAP)..."
    mkdir -p "$RATHOLE_DIR"
    if [ "$ROLE" = "kharej" ]; then
        cat > "$RATHOLE_DIR/server.toml" <<EOF
[server]
bind_addr = "0.0.0.0:${RATHOLE_PORT}"
[server.services.waterwall]
token = "${RATHOLE_TOKEN}"
connect_addr = "127.0.0.1:4433"
EOF
        create_service "rathole" "$BIN_DIR/rathole $RATHOLE_DIR/server.toml"
        cat > "$WATERWALL_DIR/server.json" <<EOF
{
    "name": "rathole_waterwall_server",
    "type": "Tunnel",
    "inbound": { "type": "TCP", "port": 4433 },
    "outbound": { "type": "TAP", "name": "tap0", "mtu": 1400, "ip": "10.0.0.2", "netmask": "255.255.255.252" }
}
EOF
        create_service "waterwall" "$BIN_DIR/WaterWall $WATERWALL_DIR/server.json"
    else
        cat > "$RATHOLE_DIR/client.toml" <<EOF
[client]
remote_addr = "${KHAREJ_IP}:${RATHOLE_PORT}"
[client.services.waterwall]
token = "${RATHOLE_TOKEN}"
local_addr = "127.0.0.1:4433"
EOF
        create_service "rathole" "$BIN_DIR/rathole $RATHOLE_DIR/client.toml"
        cat > "$WATERWALL_DIR/client.json" <<EOF
{
    "name": "rathole_waterwall_client",
    "type": "Tunnel",
    "inbound": { "type": "TAP", "name": "tap0", "mtu": 1400, "ip": "10.0.0.1", "netmask": "255.255.255.252" },
    "outbound": { "type": "TCP", "address": "127.0.0.1:4433" }
}
EOF
        create_service "waterwall" "$BIN_DIR/WaterWall $WATERWALL_DIR/client.json"
    fi
}

config_method2_cdn_simple() {
    info "Configuring Method 2: CDN + WaterWall (Simple)..."
    if [ "$ROLE" = "kharej" ]; then
        get_letsencrypt_cert "$DOMAIN"
        cat > "$WATERWALL_DIR/server_cdn.json" <<EOF
{
    "name": "cdn_waterwall_server",
    "type": "Tunnel",
    "inbound": {
        "type": "CDN",
        "password": "${CDN_PASS}",
        "port": 443,
        "tls": true,
        "cert": "/etc/ssl/certs/fullchain.pem",
        "key": "/etc/ssl/private/privkey.pem"
    },
    "outbound": { "type": "TAP", "name": "tap0", "mtu": 1400, "ip": "10.0.0.2", "netmask": "255.255.255.252" }
}
EOF
        create_service "waterwall" "$BIN_DIR/WaterWall $WATERWALL_DIR/server_cdn.json"
    else
        cat > "$WATERWALL_DIR/client_cdn.json" <<EOF
{
    "name": "cdn_waterwall_client",
    "type": "Tunnel",
    "inbound": { "type": "TAP", "name": "tap0", "mtu": 1400, "ip": "10.0.0.1", "netmask": "255.255.255.252" },
    "outbound": {
        "type": "CDN",
        "password": "${CDN_PASS}",
        "address": "${DOMAIN}:443",
        "sni": "${DOMAIN}"
    }
}
EOF
        create_service "waterwall" "$BIN_DIR/WaterWall $WATERWALL_DIR/client_cdn.json"
    fi
}

config_method3_multilayer() {
    info "Configuring Method 3: CDN + HalfDuplex + RealityTls..."
    if [ "$ROLE" = "kharej" ]; then
        get_letsencrypt_cert "$DOMAIN"
        cat > "$WATERWALL_DIR/multilayer_server.json" <<EOF
{
    "name": "multilayer_server",
    "type": "Tunnel",
    "inbound": {
        "type": "CDN",
        "password": "${CDN_PASS}",
        "port": 443,
        "tls": true,
        "cert": "/etc/ssl/certs/fullchain.pem",
        "key": "/etc/ssl/private/privkey.pem"
    },
    "routes": [
        { "type": "RealityTls", "password": "${RL_PASS}", "address": "127.0.0.1:4433" }
    ],
    "outbound": { "type": "HalfDuplex", "password": "${HD_PASS}", "address": "127.0.0.1:5000" }
}
EOF
        cat > "$WATERWALL_DIR/multilayer_server_tap.json" <<EOF
{
    "name": "tap_from_hd",
    "type": "Tunnel",
    "inbound": { "type": "HalfDuplex", "password": "${HD_PASS}", "port": 5000 },
    "outbound": { "type": "TAP", "name": "tap0", "mtu": 1200, "ip": "10.0.0.2", "netmask": "255.255.255.252" }
}
EOF
        stop_disable_service "waterwall"
        create_service "waterwall-cdn" "$BIN_DIR/WaterWall $WATERWALL_DIR/multilayer_server.json"
        create_service "waterwall-tap" "$BIN_DIR/WaterWall $WATERWALL_DIR/multilayer_server_tap.json"
    else
        cat > "$WATERWALL_DIR/multilayer_client_tap.json" <<EOF
{
    "name": "tap_to_hd",
    "type": "Tunnel",
    "inbound": { "type": "TAP", "name": "tap0", "mtu": 1200, "ip": "10.0.0.1", "netmask": "255.255.255.252" },
    "outbound": { "type": "HalfDuplex", "password": "${HD_PASS}", "address": "127.0.0.1:5000" }
}
EOF
        cat > "$WATERWALL_DIR/multilayer_client_hd.json" <<EOF
{
    "name": "hd_to_rl",
    "type": "Tunnel",
    "inbound": { "type": "HalfDuplex", "password": "${HD_PASS}", "port": 5000 },
    "outbound": { "type": "RealityTls", "password": "${RL_PASS}", "address": "127.0.0.1:4433", "sni": "www.google.com", "fingerprint": "chrome" }
}
EOF
        cat > "$WATERWALL_DIR/multilayer_client_cdn.json" <<EOF
{
    "name": "rl_to_cdn",
    "type": "Tunnel",
    "inbound": { "type": "RealityTls", "password": "${RL_PASS}", "port": 4433 },
    "outbound": { "type": "CDN", "password": "${CDN_PASS}", "address": "${DOMAIN}:443", "sni": "${DOMAIN}" }
}
EOF
        stop_disable_service "waterwall"
        create_service "waterwall-tap" "$BIN_DIR/WaterWall $WATERWALL_DIR/multilayer_client_tap.json"
        create_service "waterwall-hd" "$BIN_DIR/WaterWall $WATERWALL_DIR/multilayer_client_hd.json"
        create_service "waterwall-cdn" "$BIN_DIR/WaterWall $WATERWALL_DIR/multilayer_client_cdn.json"
    fi
}

config_method4_vless_reverse() {
    info "Configuring Method 4: VLESS Reverse + WaterWall..."
    install_xray
    systemctl stop xray 2>/dev/null || true
    systemctl disable xray 2>/dev/null || true

    if [ "$ROLE" = "iran" ]; then
        portal_addr=$(whiptail --inputbox "Portal domain or IP:" 8 50 --title "VLESS Iran" 3>&1 1>&2 2>&3)
        uuid=$(whiptail --inputbox "VLESS UUID (leave blank to generate):" 8 50 --title "UUID" 3>&1 1>&2 2>&3)
        uuid=${uuid:-$(cat /proc/sys/kernel/random/uuid)}
        pub_key=$(whiptail --inputbox "Reality public key (from Portal):" 8 50 --title "Public Key" 3>&1 1>&2 2>&3)
        short_id=$(whiptail --inputbox "Reality shortId (from Portal):" 8 50 --title "ShortId" 3>&1 1>&2 2>&3)
        server_name=$(whiptail --inputbox "Reality serverName (e.g., www.google.com):" 8 50 "www.google.com" --title "Server Name" 3>&1 1>&2 2>&3)

        cat > "$WATERWALL_DIR/iran_tap.json" <<EOF
{
    "name": "iran_tap_to_xray",
    "type": "Tunnel",
    "inbound": { "type": "TAP", "name": "tap0", "mtu": 1400, "ip": "10.0.0.1", "netmask": "255.255.255.252" },
    "outbound": { "type": "TCP", "address": "127.0.0.1:4433" }
}
EOF
        stop_disable_service "waterwall"
        create_service "waterwall" "$BIN_DIR/WaterWall $WATERWALL_DIR/iran_tap.json"

        cat > "$XRAY_CONFIG" <<EOF
{
  "log": { "loglevel": "warning" },
  "inbounds": [{
    "port": 4433,
    "protocol": "dokodemo-door",
    "settings": { "address": "127.0.0.1", "port": 1080, "network": "tcp" },
    "tag": "local_in"
  }],
  "outbounds": [{
    "protocol": "vless",
    "settings": {
      "vnext": [{
        "address": "${portal_addr}",
        "port": 443,
        "users": [{ "id": "${uuid}", "encryption": "none", "flow": "xtls-rprx-vision" }]
      }]
    },
    "streamSettings": {
      "network": "tcp",
      "security": "reality",
      "realitySettings": {
        "show": false,
        "serverName": "${server_name}",
        "fingerprint": "chrome",
        "publicKey": "${pub_key}",
        "shortId": "${short_id}",
        "spiderX": "/"
      }
    },
    "tag": "proxy"
  }]
}
EOF
        systemctl enable xray
        systemctl start xray

    elif [ "$ROLE" = "portal" ]; then
        backend_ip=$(whiptail --inputbox "Backend IP (dirty IP):" 8 50 --title "Backend Address" 3>&1 1>&2 2>&3)
        uuid=$(whiptail --inputbox "VLESS UUID (leave blank to generate):" 8 50 --title "UUID" 3>&1 1>&2 2>&3)
        uuid=${uuid:-$(cat /proc/sys/kernel/random/uuid)}
        priv_key=$(whiptail --inputbox "Reality private key (press enter to generate):" 8 50 --title "Private Key" 3>&1 1>&2 2>&3)
        if [ -z "$priv_key" ]; then
            keys=$(xray x25519)
            priv_key=$(echo "$keys" | grep "Private" | awk '{print $3}')
            pub_key=$(echo "$keys" | grep "Public" | awk '{print $3}')
            whiptail --msgbox "Generated Public Key: $pub_key\nSave this for Iran client." 10 60
        else
            pub_key=$(whiptail --inputbox "Public key:" 8 50 --title "Public Key" 3>&1 1>&2 2>&3)
        fi
        short_id=$(whiptail --inputbox "ShortId (random string):" 8 50 --title "ShortId" 3>&1 1>&2 2>&3)
        server_name=$(whiptail --inputbox "Reality serverName (e.g., www.google.com):" 8 50 "www.google.com" --title "Server Name" 3>&1 1>&2 2>&3)

        cat > "$XRAY_CONFIG" <<EOF
{
  "log": { "loglevel": "warning" },
  "inbounds": [{
    "port": 443,
    "protocol": "vless",
    "settings": {
      "clients": [{ "id": "${uuid}", "flow": "xtls-rprx-vision" }],
      "decryption": "none"
    },
    "streamSettings": {
      "network": "tcp",
      "security": "reality",
      "realitySettings": {
        "show": false,
        "dest": "${backend_ip}:8443",
        "xver": 0,
        "serverNames": ["${server_name}"],
        "privateKey": "${priv_key}",
        "shortIds": ["${short_id}"]
      }
    },
    "tag": "in_portal"
  }],
  "outbounds": [{
    "protocol": "vless",
    "settings": {
      "vnext": [{
        "address": "${backend_ip}",
        "port": 8443,
        "users": [{ "id": "${uuid}", "encryption": "none" }]
      }]
    },
    "streamSettings": { "network": "tcp", "security": "none" },
    "tag": "to_backend"
  }]
}
EOF
        systemctl enable xray
        systemctl start xray

    elif [ "$ROLE" = "backend" ]; then
        uuid=$(whiptail --inputbox "VLESS UUID (same as portal):" 8 50 --title "UUID" 3>&1 1>&2 2>&3)
        cat > "$XRAY_CONFIG" <<EOF
{
  "log": { "loglevel": "warning" },
  "inbounds": [{
    "port": 8443,
    "protocol": "vless",
    "settings": {
      "clients": [{ "id": "${uuid}", "encryption": "none" }],
      "decryption": "none"
    },
    "streamSettings": { "network": "tcp", "security": "none" },
    "tag": "in_backend"
  }],
  "outbounds": [{
    "protocol": "dokodemo-door",
    "settings": { "address": "127.0.0.1", "port": 4433, "network": "tcp" },
    "tag": "to_waterwall"
  }]
}
EOF
        systemctl enable xray
        systemctl start xray

        cat > "$WATERWALL_DIR/backend_tap.json" <<EOF
{
    "name": "backend_waterwall",
    "type": "Tunnel",
    "inbound": { "type": "TCP", "port": 4433 },
    "outbound": { "type": "TAP", "name": "tap0", "mtu": 1400, "ip": "10.0.0.2", "netmask": "255.255.255.252" }
}
EOF
        stop_disable_service "waterwall"
        create_service "waterwall" "$BIN_DIR/WaterWall $WATERWALL_DIR/backend_tap.json"
    fi
}

# ==================== ADVANCED MENU FUNCTIONS ====================

view_logs() {
    local service=$(whiptail --title "View Logs" --menu "Select service:" 15 50 5 \
        "waterwall" "WaterWall" \
        "rathole" "Rathole" \
        "xray" "Xray" \
        "all" "All services (last 20 lines each)" \
        3>&1 1>&2 2>&3)
    if [ "$service" = "all" ]; then
        logs=""
        for s in waterwall rathole xray; do
            logs+="=== $s ===\n$(journalctl -u "$s" -n 20 --no-pager 2>&1)\n\n"
        done
        whiptail --title "Logs (all)" --msgbox "$logs" 25 80
    else
        logs=$(journalctl -u "$service" -n 50 --no-pager 2>&1)
        whiptail --title "Logs: $service" --msgbox "$logs" 20 80
    fi
}

change_settings() {
    local new_port=$(whiptail --inputbox "New Rathole port (current: $RATHOLE_PORT):" 8 50 "$RATHOLE_PORT" --title "Change Port" 3>&1 1>&2 2>&3)
    if [ -n "$new_port" ] && [ "$new_port" != "$RATHOLE_PORT" ]; then
        RATHOLE_PORT=$new_port
        whiptail --msgbox "Rathole port updated to $RATHOLE_PORT.\nYou may need to reinstall the tunnel for changes to take effect." 10 50
    fi
}

restart_services() {
    for s in waterwall rathole xray; do
        systemctl restart $s 2>/dev/null || true
    done
    whiptail --msgbox "All services restarted." 8 40
}

stop_services() {
    for s in waterwall rathole xray; do
        systemctl stop $s 2>/dev/null || true
    done
    whiptail --msgbox "All services stopped." 8 40
}

uninstall_everything() {
    if whiptail --title "Uninstall" --yesno "This will remove all tunnels, TAP interfaces, and services. Continue?" 10 50; then
        stop_services
        for s in waterwall rathole xray; do
            systemctl disable $s 2>/dev/null || true
            rm -f "/etc/systemd/system/${s}.service"
        done
        systemctl daemon-reload
        rm -rf "$WATERWALL_DIR" "$RATHOLE_DIR"
        rm -f "$BIN_DIR/WaterWall" "$BIN_DIR/rathole"
        ip link delete tap0 2>/dev/null || true
        whiptail --msgbox "Uninstall completed." 8 40
    fi
}

install_tunnel() {
    # 1. Select method
    METHOD=$(whiptail --title "Select Method" --menu "Tunneling Method" 15 60 4 \
        "1" "Rathole + WaterWall (TAP)" \
        "2" "ArvanCloud CDN + WaterWall (Simple)" \
        "3" "CDN + HalfDuplex + RealityTls (Ultra)" \
        "4" "VLESS Reverse (Xray) + WaterWall" \
        3>&1 1>&2 2>&3)
    [ -z "$METHOD" ] && return

    # 2. Select role
    if [ "$METHOD" != "4" ]; then
        ROLE=$(whiptail --title "Server Role" --menu "This server is:" 12 50 2 \
            "iran" "Iran (inside, behind NAT)" \
            "kharej" "Kharej (outside, public IP)" \
            3>&1 1>&2 2>&3)
    else
        ROLE=$(whiptail --title "VLESS Role" --menu "Select role:" 12 50 3 \
            "iran" "Iran Client" \
            "portal" "Portal (clean IP)" \
            "backend" "Backend (dirty IP)" \
            3>&1 1>&2 2>&3)
    fi
    [ -z "$ROLE" ] && return

    # 3. Ask for method-specific parameters (including passwords)

    # Method 1: Rathole
    if [ "$METHOD" = "1" ]; then
        if [ "$ROLE" = "iran" ]; then
            KHAREJ_IP=$(whiptail --inputbox "Kharej public IP:" 8 50 --title "Rathole" 3>&1 1>&2 2>&3)
            [ -z "$KHAREJ_IP" ] && return
        fi
        PORT_TMP=$(whiptail --inputbox "Rathole port [443]:" 8 50 "443" --title "Port" 3>&1 1>&2 2>&3)
        RATHOLE_PORT=${PORT_TMP:-443}
        RATHOLE_TOKEN=$(whiptail --inputbox "Rathole authentication token (strong password):" 8 50 "MyRatholeToken123" --title "Rathole Token" 3>&1 1>&2 2>&3)
        [ -z "$RATHOLE_TOKEN" ] && RATHOLE_TOKEN="MyRatholeToken123"
    fi

    # Methods 2 & 3: CDN based
    if [ "$METHOD" = "2" ] || [ "$METHOD" = "3" ]; then
        DOMAIN=$(whiptail --inputbox "Your domain (e.g., vpn.domain.com):" 8 50 --title "CDN Domain" 3>&1 1>&2 2>&3)
        [ -z "$DOMAIN" ] && return
        CDN_PASS=$(whiptail --passwordbox "CDN password (WaterWall authentication):" 8 50 --title "CDN Password" 3>&1 1>&2 2>&3)
        [ -z "$CDN_PASS" ] && CDN_PASS="MyCDNpass"
        if [ "$METHOD" = "3" ]; then
            HD_PASS=$(whiptail --passwordbox "HalfDuplex password:" 8 50 --title "HalfDuplex Password" 3>&1 1>&2 2>&3)
            [ -z "$HD_PASS" ] && HD_PASS="MyHDpass"
            RL_PASS=$(whiptail --passwordbox "RealityTls password:" 8 50 --title "RealityTls Password" 3>&1 1>&2 2>&3)
            [ -z "$RL_PASS" ] && RL_PASS="MyRLpass"
        fi
    fi

    # Method 4: VLESS Reverse - passwords are not needed here (uses UUID and keys), but we ask nothing extra

    whiptail --title "Confirm" --yesno "Method: $METHOD\nRole: $ROLE\nProceed?" 10 50 || return

    # Installation steps
    install_pkgs
    download_waterwall
    mkdir -p "$WATERWALL_DIR"

    case "$METHOD" in
        1)
            download_rathole
            config_method1_rathole
            ;;
        2)
            config_method2_cdn_simple
            ;;
        3)
            config_method3_multilayer
            ;;
        4)
            config_method4_vless_reverse
            ;;
    esac

    if [[ "$ROLE" =~ ^(kharej|portal|backend)$ ]]; then
        ufw allow 443/tcp 2>/dev/null || true
        info "Port 443 opened."
    fi

    whiptail --msgbox "Installation finished.\nFrom Iran, test with: ping 10.0.0.2" 10 50
}

# ==================== MAIN MENU ====================

main_menu() {
    while true; do
        CHOICE=$(whiptail --title "L2 Tunnel Installer - Advanced Menu v2.1" \
            --menu "Choose an option:" 18 70 8 \
            "1" "Install / Configure Tunnel" \
            "2" "View Logs (WaterWall / Rathole / Xray)" \
            "3" "Change Settings (Ports)" \
            "4" "Restart All Services" \
            "5" "Stop All Services" \
            "6" "Uninstall Everything" \
            "7" "Exit" \
            3>&1 1>&2 2>&3)

        case $CHOICE in
            1) install_tunnel ;;
            2) view_logs ;;
            3) change_settings ;;
            4) restart_services ;;
            5) stop_services ;;
            6) uninstall_everything ;;
            7) exit 0 ;;
            *) continue ;;
        esac
    done
}

# Run as root
if [[ $EUID -ne 0 ]]; then
    echo -e "${RED}This script must be run as root.${NC}"
    exit 1
fi

main_menu