#!/bin/bash
# ===========================================
# ZRAM Swap Setup Script for Ubuntu
# Author: Kh4n
# ===========================================

set -e

# Color codes for output
GREEN="\e[32m"
RED="\e[31m"
YELLOW="\e[33m"
RESET="\e[0m"

log() {
    echo -e "${GREEN}[+]${RESET} $1"
}

error() {
    echo -e "${RED}[x]${RESET} $1" >&2
}

check_root() {
    if [ "$EUID" -ne 0 ]; then
        error "Please run this script with root privileges (sudo)"
        exit 1
    fi
}

install_pkg() {
    if ! dpkg -s systemd-zram-generator &>/dev/null; then
        log "Installing systemd-zram-generator..."
        apt update -y && apt install -y systemd-zram-generator
    else
        log "✅ systemd-zram-generator is already installed."
    fi
}

configure_zram() {
    log "Creating configuration file /etc/systemd/zram-generator.conf ..."
    cat > /etc/systemd/zram-generator.conf <<EOF
[zram0]
zram-size = ram * 0.5
compression-algorithm = zstd
EOF
}

enable_zram() {
    log "Reloading systemd..."
    systemctl daemon-reload

    log "Starting ZRAM service..."
    systemctl start systemd-zram-setup@zram0.service || true

    sleep 1
    if swapon --show | grep -q zram0; then
        log "🎉 ZRAM is now active and working!"
    else
        error "ZRAM failed to start. Check status with: systemctl status systemd-zram-setup@zram0"
    fi
}

show_status() {
    echo -e "\n${YELLOW}=== ZRAM Status ===${RESET}"
    swapon --show || echo "No swap devices active."
    echo
    lsblk | grep zram || true
    echo
    cat /sys/block/zram0/comp_algorithm 2>/dev/null || true
}

main() {
    check_root
    install_pkg
    configure_zram
    enable_zram
    show_status
    log "✅ ZRAM setup completed successfully."
}

main "$@"
