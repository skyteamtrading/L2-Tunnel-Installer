#!/bin/bash
set -euo pipefail

RED='\033[0;31m'; GREEN='\033[0;32m'; YELLOW='\033[1;33m'; BLUE='\033[0;34m'; NC='\033[0m'
info() { echo -e "${GREEN}[INFO]${NC} $1"; }
warn() { echo -e "${YELLOW}[WARN]${NC} $1"; }
err()  { echo -e "${RED}[ERROR]${NC} $1"; exit 1; }

METHOD=""
ROLE=""
WATERWALL_DIR="/etc/waterwall"
RATHOLE_DIR="/etc/rathole"
XRAY_CONFIG="/usr/local/etc/xray/config.json"
BIN_DIR="/usr/local/bin"
RATHOLE_PORT=443

function install_pkgs() {
    info "Updating packages..."
    apt update && apt upgrade -y
    apt install -y wget unzip openssl jq
}

function download_waterwall() {
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

function download_rathole() {
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

function install_xray() {
    if [ -f "$BIN_DIR/xray" ]; then
        info "Xray already installed."
    else
        info "Installing Xray via official script..."
        bash -c "$(curl -L https://github.com/XTLS/Xray-install/raw/main/install-release.sh)" @ install
        info "Xray installed."
    fi
}

function generate_ssl_cert() {
    local domain=$1
    mkdir -p /etc/ssl/{private,certs}
    if [ ! -f "/etc/ssl/certs/fullchain.pem" ]; then
        info "Generating self-signed SSL certificate for $domain..."
        openssl req -x509 -newkey rsa:4096 \
            -keyout /etc/ssl/private/privkey.pem \
            -out /etc/ssl/certs/fullchain.pem \
            -days 3650 -nodes \
            -subj "/CN=$domain"
    fi
}

function create_service() {
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

function stop_disable_service() {
    local name=$1
    systemctl stop "$name" 2>/dev/null || true
    systemctl disable "$name" 2>/dev/null || true
    rm -f "/etc/systemd/system/${name}.service"
    systemctl daemon-reload
}

# --------------- METHOD 1 : Rathole + WaterWall (TAP) ---------------
config_method1_rathole() {
    info "Configuring Method 1: Rathole + WaterWall (TAP)..."
    if [ "$ROLE" = "kharej" ]; then
        cat > "$RATHOLE_DIR/server.toml" <<EOF
[server]
bind_addr = "0.0.0.0:${RATHOLE_PORT}"
[server.services.tap]
bind_addr = "0.0.0.0:${RATHOLE_PORT}"
EOF
        create_service "rathole" "$BIN_DIR/rathole $RATHOLE_DIR/server.toml"

        cat > "$WATERWALL_DIR/server_tap.json" <<EOF
{
    "name": "rathole_to_tap",
    "type": "Tunnel",
    "inbound": { "type": "TCP", "port": 4433 },
    "outbound": { "type": "TAP", "name": "tap0", "mtu": 1400, "ip": "10.0.0.2", "netmask": "255.255.255.252" }
}
EOF
        create_service "waterwall" "$BIN_DIR/WaterWall $WATERWALL_DIR/server_tap.json"
    else
        local kharej_ip=$1
        cat > "$RATHOLE_DIR/client.toml" <<EOF
[client]
remote_addr = "${kharej_ip}:${RATHOLE_PORT}"
[client.services.tap]
local_addr = "127.0.0.1:4433"
remote_addr = "127.0.0.1:4433"
EOF
        create_service "rathole" "$BIN_DIR/rathole $RATHOLE_DIR/client.toml"

        cat > "$WATERWALL_DIR/client_tap.json" <<EOF
{
    "name": "tap_to_rathole",
    "type": "Tunnel",
    "inbound": { "type": "TAP", "name": "tap0", "mtu": 1400, "ip": "10.0.0.1", "netmask": "255.255.255.252" },
    "outbound": { "type": "TCP", "address": "127.0.0.1:4433" }
}
EOF
        create_service "waterwall" "$BIN_DIR/WaterWall $WATERWALL_DIR/client_tap.json"
    fi
}

# --------------- METHOD 2 : CDN Simple ---------------
config_method2_cdn() {
    info "Configuring Method 2: CDN + WaterWall (Simple)..."
    local domain=$1
    if [ "$ROLE" = "kharej" ]; then
        generate_ssl_cert "$domain"
        cat > "$WATERWALL_DIR/server_cdn.json" <<EOF
{
    "name": "cdn_to_tap",
    "type": "Tunnel",
    "inbound": {
        "type": "CDN", "password": "MyCDNpass", "port": 443, "tls": true,
        "cert": "/etc/ssl/certs/fullchain.pem", "key": "/etc/ssl/private/privkey.pem"
    },
    "outbound": { "type": "TAP", "name": "tap0", "mtu": 1400, "ip": "10.0.0.2", "netmask": "255.255.255.252" }
}
EOF
        create_service "waterwall" "$BIN_DIR/WaterWall $WATERWALL_DIR/server_cdn.json"
    else
        cat > "$WATERWALL_DIR/client_cdn.json" <<EOF
{
    "name": "tap_to_cdn",
    "type": "Tunnel",
    "inbound": { "type": "TAP", "name": "tap0", "mtu": 1400, "ip": "10.0.0.1", "netmask": "255.255.255.252" },
    "outbound": { "type": "CDN", "password": "MyCDNpass", "address": "${domain}:443", "sni": "${domain}" }
}
EOF
        create_service "waterwall" "$BIN_DIR/WaterWall $WATERWALL_DIR/client_cdn.json"
    fi
}

# --------------- METHOD 3 : CDN Multi-layer ---------------
config_method3_multilayer() {
    info "Configuring Method 3: CDN + HalfDuplex + RealityTls + WaterWall..."
    local domain=$1
    if [ "$ROLE" = "kharej" ]; then
        generate_ssl_cert "$domain"
        cat > "$WATERWALL_DIR/layer1_hd.json" <<EOF
{"name":"hd_to_tap","type":"Tunnel","inbound":{"type":"HalfDuplex","password":"MyHDpass","port":5000},"outbound":{"type":"TAP","name":"tap0","mtu":1200,"ip":"10.0.0.2","netmask":"255.255.255.252"}}
EOF
        cat > "$WATERWALL_DIR/layer2_reality.json" <<EOF
{"name":"rl_to_hd","type":"Tunnel","inbound":{"type":"RealityTls","password":"MyRLpass","port":4433},"outbound":{"type":"HalfDuplex","password":"MyHDpass","address":"127.0.0.1:5000"}}
EOF
        cat > "$WATERWALL_DIR/layer3_cdn.json" <<EOF
{"name":"cdn_to_rl","type":"Tunnel","inbound":{"type":"CDN","password":"MyCDNpass","port":443,"tls":true,"cert":"/etc/ssl/certs/fullchain.pem","key":"/etc/ssl/private/privkey.pem"},"outbound":{"type":"RealityTls","password":"MyRLpass","address":"127.0.0.1:4433"}}
EOF
        stop_disable_service "waterwall"
        create_service "waterwall-l1" "$BIN_DIR/WaterWall $WATERWALL_DIR/layer1_hd.json"
        create_service "waterwall-l2" "$BIN_DIR/WaterWall $WATERWALL_DIR/layer2_reality.json"
        create_service "waterwall-l3" "$BIN_DIR/WaterWall $WATERWALL_DIR/layer3_cdn.json"
    else
        cat > "$WATERWALL_DIR/layer1_hd.json" <<EOF
{"name":"tap_to_hd","type":"Tunnel","inbound":{"type":"TAP","name":"tap0","mtu":1200,"ip":"10.0.0.1","netmask":"255.255.255.252"},"outbound":{"type":"HalfDuplex","password":"MyHDpass","address":"127.0.0.1:5000"}}
EOF
        cat > "$WATERWALL_DIR/layer2_reality.json" <<EOF
{"name":"hd_to_rl","type":"Tunnel","inbound":{"type":"HalfDuplex","password":"MyHDpass","port":5000},"outbound":{"type":"RealityTls","password":"MyRLpass","address":"127.0.0.1:4433","sni":"www.google.com","fingerprint":"chrome"}}
EOF
        cat > "$WATERWALL_DIR/layer3_cdn.json" <<EOF
{"name":"rl_to_cdn","type":"Tunnel","inbound":{"type":"RealityTls","password":"MyRLpass","port":4433},"outbound":{"type":"CDN","password":"MyCDNpass","address":"${domain}:443","sni":"${domain}"}}
EOF
        stop_disable_service "waterwall"
        create_service "waterwall-l1" "$BIN_DIR/WaterWall $WATERWALL_DIR/layer1_hd.json"
        create_service "waterwall-l2" "$BIN_DIR/WaterWall $WATERWALL_DIR/layer2_reality.json"
        create_service "waterwall-l3" "$BIN_DIR/WaterWall $WATERWALL_DIR/layer3_cdn.json"
    fi
}

# --------------- METHOD 4 : VLESS Reverse + WaterWall ---------------
config_method4_vless_reverse() {
    info "Configuring Method 4: VLESS Reverse + WaterWall (TAP)..."
    install_xray
    systemctl stop xray 2>/dev/null || true
    systemctl disable xray 2>/dev/null || true

    if [ "$ROLE" = "iran" ]; then
        read -p "Portal domain or IP: " portal_addr
        read -p "VLESS UUID (leave blank to generate): " uuid
        uuid=${uuid:-$(cat /proc/sys/kernel/random/uuid)}
        read -p "Reality public key (from Portal): " pub_key
        read -p "Reality shortId (from Portal): " short_id
        read -p "Reality serverName (e.g., www.google.com): " server_name
        server_name=${server_name:-www.google.com}

        cat > "$WATERWALL_DIR/client_tap.json" <<EOF
{
    "name": "tap_to_xray",
    "type": "Tunnel",
    "inbound": { "type": "TAP", "name": "tap0", "mtu": 1400, "ip": "10.0.0.1", "netmask": "255.255.255.252" },
    "outbound": { "type": "TCP", "address": "127.0.0.1:4433" }
}
EOF
        stop_disable_service "waterwall"
        create_service "waterwall" "$BIN_DIR/WaterWall $WATERWALL_DIR/client_tap.json"

        cat > "$XRAY_CONFIG" <<EOF
{
  "log": { "loglevel": "warning" },
  "inbounds": [
    {
      "port": 4433,
      "protocol": "dokodemo-door",
      "settings": { "address": "127.0.0.1", "port": 4433, "network": "tcp" },
      "tag": "local_in"
    }
  ],
  "outbounds": [
    {
      "protocol": "vless",
      "settings": {
        "vnext": [
          {
            "address": "${portal_addr}",
            "port": 443,
            "users": [
              {
                "id": "${uuid}",
                "encryption": "none",
                "flow": "xtls-rprx-vision"
              }
            ]
          }
        ]
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
    }
  ]
}
EOF
        systemctl enable xray
        systemctl start xray
        info "Xray client started."

    elif [ "$ROLE" = "portal" ]; then
        read -p "Backend IP (dirty IP): " backend_ip
        read -p "VLESS UUID (leave blank to generate): " uuid
        uuid=${uuid:-$(cat /proc/sys/kernel/random/uuid)}
        read -p "Reality private key (generate? [y/n]): " gen_key
        if [ "$gen_key" = "y" ]; then
            keys=$(xray x25519)
            priv_key=$(echo "$keys" | grep "Private" | awk '{print $3}')
            pub_key=$(echo "$keys" | grep "Public" | awk '{print $3}')
        else
            read -p "Private key: " priv_key
            read -p "Public key: " pub_key
        fi
        read -p "ShortId (random string, e.g., abc123): " short_id
        read -p "Reality serverName (e.g., www.google.com): " server_name
        server_name=${server_name:-www.google.com}

        echo -e "${GREEN}Reality Public Key: ${pub_key}${NC}"
        echo -e "${GREEN}ShortId: ${short_id}${NC}"
        echo -e "${GREEN}UUID: ${uuid}${NC}"

        cat > "$XRAY_CONFIG" <<EOF
{
  "log": { "loglevel": "warning" },
  "inbounds": [
    {
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
          "dest": "127.0.0.1:8443",
          "xver": 0,
          "serverNames": ["${server_name}"],
          "privateKey": "${priv_key}",
          "shortIds": ["${short_id}"]
        }
      },
      "tag": "inbound_portal"
    }
  ],
  "outbounds": [
    {
      "protocol": "vless",
      "settings": {
        "vnext": [
          {
            "address": "${backend_ip}",
            "port": 8443,
            "users": [{ "id": "${uuid}", "encryption": "none" }]
          }
        ]
      },
      "streamSettings": { "network": "tcp", "security": "none" },
      "tag": "to_backend"
    }
  ],
  "reverse": {
    "bridges": [{ "tag": "bridge", "domain": "reverse-proxy.internal" }]
  }
}
EOF
        systemctl enable xray
        systemctl start xray
        info "Xray portal started."

    elif [ "$ROLE" = "backend" ]; then
        read -p "VLESS UUID (same as portal): " uuid
        uuid=${uuid:-$(cat /proc/sys/kernel/random/uuid)}

        cat > "$XRAY_CONFIG" <<EOF
{
  "log": { "loglevel": "warning" },
  "inbounds": [
    {
      "port": 8443,
      "protocol": "vless",
      "settings": {
        "clients": [{ "id": "${uuid}", "encryption": "none" }],
        "decryption": "none"
      },
      "streamSettings": { "network": "tcp", "security": "none" },
      "tag": "inbound_backend"
    }
  ],
  "outbounds": [{ "protocol": "freedom", "settings": {}, "tag": "direct" }],
  "reverse": {
    "portals": [{ "tag": "portal", "domain": "reverse-proxy.internal" }]
  }
}
EOF
        systemctl enable xray
        systemctl start xray
        info "Xray backend started."

        cat > "$WATERWALL_DIR/server_tap.json" <<EOF
{
    "name": "xray_to_tap",
    "type": "Tunnel",
    "inbound": { "type": "TCP", "port": 4433 },
    "outbound": { "type": "TAP", "name": "tap0", "mtu": 1400, "ip": "10.0.0.2", "netmask": "255.255.255.252" }
}
EOF
        stop_disable_service "waterwall"
        create_service "waterwall" "$BIN_DIR/WaterWall $WATERWALL_DIR/server_tap.json"
        info "WaterWall backend server started."
    fi
}

# --------------- MAIN MENU ---------------
function main_menu() {
    clear
    echo -e "${BLUE}============================================${NC}"
    echo -e "${BLUE}   L2 Tunnel Installer (4 Methods)   ${NC}"
    echo -e "${BLUE}============================================${NC}"
    echo ""
    echo "Choose tunneling method:"
    echo " 1) Rathole + WaterWall (TAP)"
    echo " 2) ArvanCloud CDN + WaterWall (Simple)"
    echo " 3) CDN + HalfDuplex + RealityTls (Ultra Secure)"
    echo " 4) VLESS Reverse (Xray) + WaterWall (TAP)"
    echo " 5) Exit"
    echo ""
    read -p "Enter choice [1-5]: " method_choice

    case "$method_choice" in
        1) METHOD="rathole";;
        2) METHOD="cdn_simple";;
        3) METHOD="cdn_multilayer";;
        4) METHOD="vless_reverse";;
        5) exit 0;;
        *) err "Invalid option";;
    esac

    if [ "$METHOD" = "vless_reverse" ]; then
        echo ""
        echo "Select server role:"
        echo " 1) Iran (client)"
        echo " 2) Portal (clean IP, outside)"
        echo " 3) Backend (dirty IP, outside)"
        read -p "Enter role [1-3]: " role_choice
        case "$role_choice" in
            1) ROLE="iran";;
            2) ROLE="portal";;
            3) ROLE="backend";;
            *) err "Invalid role";;
        esac
    else
        echo ""
        echo "Which server is this?"
        echo " 1) Iran (inside, behind NAT)"
        echo " 2) Kharej (outside, public IP)"
        read -p "Enter choice [1-2]: " srv
        if [ "$srv" = "1" ]; then ROLE="iran"; else ROLE="kharej"; fi
    fi

    local kharej_ip=""
    local domain=""

    case "$METHOD" in
        rathole)
            if [ "$ROLE" = "iran" ]; then
                read -p "Kharej public IP: " kharej_ip
            fi
            read -p "Rathole port [443]: " tmp; RATHOLE_PORT=${tmp:-443}
            ;;
        cdn_simple|cdn_multilayer)
            read -p "Your domain (e.g., vpn.mydomain.ir): " domain
            [ -z "$domain" ] && err "Domain required"
            ;;
        vless_reverse)
            ;; # parameters asked inside config
    esac

    echo ""
    info "Method: $METHOD, Role: $ROLE"
    [ -n "$kharej_ip" ] && info "Kharej IP: $kharej_ip"
    [ -n "$domain" ] && info "Domain: $domain"
    read -p "Proceed? (y/n): " confirm
    [ "$confirm" != "y" ] && { echo "Aborted."; exit 1; }

    install_pkgs
    download_waterwall
    mkdir -p "$WATERWALL_DIR"

    case "$METHOD" in
        rathole)
            download_rathole; mkdir -p "$RATHOLE_DIR"
            config_method1_rathole "$kharej_ip"
            ;;
        cdn_simple)
            config_method2_cdn "$domain"
            ;;
        cdn_multilayer)
            config_method3_multilayer "$domain"
            ;;
        vless_reverse)
            config_method4_vless_reverse
            ;;
    esac

    if [ "$ROLE" = "kharej" ] || [ "$ROLE" = "portal" ] || [ "$ROLE" = "backend" ]; then
        ufw allow 443/tcp 2>/dev/null || true
        info "Firewall: port 443/tcp opened."
    fi

    echo ""
    info "Installation finished."
    if [ "$METHOD" = "vless_reverse" ]; then
        echo "Please ensure portal and backend can reach each other on port 8443."
        echo "Iran pings 10.0.0.2 after setup."
    else
        echo "Ping 10.0.0.2 from Iran to test."
    fi
}

main_menu
