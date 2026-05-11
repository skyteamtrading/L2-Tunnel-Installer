#!/bin/bash
set -euo pipefail

RED='\033[0;31m'; GREEN='\033[0;32m'; YELLOW='\033[1;33m'; BLUE='\033[0;34m'; NC='\033[0m'
info() { echo -e "${GREEN}[INFO]${NC} $1"; }
warn() { echo -e "${YELLOW}[WARN]${NC} $1"; }
err()  { echo -e "${RED}[ERROR]${NC} $1"; exit 1; }

# (اینجا اسکریپت کامل نصب را که قبلاً ارائه دادم قرار دهید)
# برای شروع، یک اسکریپت نمونه می‌گذاریم
echo "L2 Tunnel Installer - Please replace with full script"
