#!/bin/bash
# ===========================================
# Automated Swap File Setup for Ubuntu
# Author: Kh4n
# Based on: DigitalOcean Guide
# ===========================================

set -e

# Color codes
GREEN="\e[32m"
RED="\e[31m"
YELLOW="\e[33m"
BLUE="\e[34m"
RESET="\e[0m"

SWAP_FILE="/swapfile"

log() {
    echo -e "${GREEN}[+]${RESET} $1"
}

error() {
    echo -e "${RED}[x]${RESET} $1" >&2
}

warn() {
    echo -e "${YELLOW}[!]${RESET} $1"
}

info() {
    echo -e "${BLUE}[i]${RESET} $1"
}

check_root() {
    if [ "$EUID" -ne 0 ]; then
        error "Please run this script with sudo privileges"
        exit 1
    fi
}

get_total_ram() {
    # Get total RAM in MB
    local ram_mb=$(free -m | awk '/^Mem:/{print $2}')
    echo "$ram_mb"
}

check_existing_swap() {
    if swapon --show | grep -q .; then
        warn "Swap is already active on the system:"
        swapon --show
        echo ""
        read -p "Do you want to continue and add additional swap? (y/N): " -n 1 -r
        echo
        if [[ ! $REPLY =~ ^[Yy]$ ]]; then
            info "Exiting without changes"
            exit 0
        fi
    fi
}

check_disk_space() {
    local required_space=$1
    local available_space=$(df / | awk 'NR==2 {print $4}')
    
    # Convert to MB (df shows in KB by default)
    available_space=$((available_space / 1024))
    
    if [ "$available_space" -lt "$required_space" ]; then
        error "Not enough disk space. Required: ${required_space}MB, Available: ${available_space}MB"
        exit 1
    fi
    
    info "Disk space check passed. Available: ${available_space}MB"
}

remove_existing_swapfile() {
    if [ -f "$SWAP_FILE" ]; then
        warn "Swap file $SWAP_FILE already exists"
        
        # Turn off swap if active
        if swapon --show | grep -q "$SWAP_FILE"; then
            log "Deactivating existing swap file..."
            swapoff "$SWAP_FILE"
        fi
        
        # Remove from fstab
        if grep -q "$SWAP_FILE" /etc/fstab; then
            log "Removing swap entry from /etc/fstab..."
            sed -i "\|$SWAP_FILE|d" /etc/fstab
        fi
        
        log "Removing old swap file..."
        rm -f "$SWAP_FILE"
    fi
}

create_swap_file() {
    local size_gb=$1
    
    log "Creating ${size_gb}GB swap file at $SWAP_FILE..."
    
    # Use fallocate for faster creation
    if command -v fallocate &> /dev/null; then
        fallocate -l "${size_gb}G" "$SWAP_FILE"
    else
        # Fallback to dd if fallocate is not available
        warn "fallocate not available, using dd (slower)..."
        dd if=/dev/zero of="$SWAP_FILE" bs=1M count=$((size_gb * 1024)) status=progress
    fi
    
    # Set correct permissions
    log "Setting secure permissions..."
    chmod 600 "$SWAP_FILE"
    
    # Verify
    ls -lh "$SWAP_FILE"
}

setup_swap() {
    log "Formatting swap file..."
    mkswap "$SWAP_FILE"
    
    log "Enabling swap file..."
    swapon "$SWAP_FILE"
    
    # Verify
    if swapon --show | grep -q "$SWAP_FILE"; then
        log "Swap file activated successfully"
    else
        error "Failed to activate swap file"
        exit 1
    fi
}

make_permanent() {
    log "Making swap permanent across reboots..."
    
    # Backup fstab
    cp /etc/fstab /etc/fstab.bak.$(date +%Y%m%d_%H%M%S)
    
    # Add to fstab if not already present
    if ! grep -q "$SWAP_FILE" /etc/fstab; then
        echo "$SWAP_FILE none swap sw 0 0" >> /etc/fstab
        log "Added swap entry to /etc/fstab"
    fi
}

configure_swappiness() {
    local swappiness=${1:-10}
    
    log "Configuring swappiness to $swappiness..."
    sysctl vm.swappiness="$swappiness"
    
    # Make permanent
    if grep -q "^vm.swappiness" /etc/sysctl.conf; then
        sed -i "s/^vm.swappiness.*/vm.swappiness=$swappiness/" /etc/sysctl.conf
    else
        echo "vm.swappiness=$swappiness" >> /etc/sysctl.conf
    fi
}

configure_cache_pressure() {
    local pressure=${1:-50}
    
    log "Configuring cache pressure to $pressure..."
    sysctl vm.vfs_cache_pressure="$pressure"
    
    # Make permanent
    if grep -q "^vm.vfs_cache_pressure" /etc/sysctl.conf; then
        sed -i "s/^vm.vfs_cache_pressure.*/vm.vfs_cache_pressure=$pressure/" /etc/sysctl.conf
    else
        echo "vm.vfs_cache_pressure=$pressure" >> /etc/sysctl.conf
    fi
}

show_status() {
    echo ""
    echo -e "${YELLOW}=== Swap Status ===${RESET}"
    swapon --show
    echo ""
    free -h
    echo ""
    info "Swappiness: $(cat /proc/sys/vm/swappiness)"
    info "Cache Pressure: $(cat /proc/sys/vm/vfs_cache_pressure)"
}

print_usage() {
    cat << EOF
Usage: $0 [SIZE_IN_GB]

Creates and configures a swap file on Ubuntu.

Arguments:
  SIZE_IN_GB    Size of swap file in GB (optional)
                If not provided, defaults to total RAM size

Examples:
  $0           # Create swap = total RAM
  $0 2         # Create 2GB swap
  $0 4         # Create 4GB swap

Recommended sizes:
  - RAM <= 2GB:  Set swap = 2x RAM
  - RAM 2-8GB:   Set swap = RAM
  - RAM > 8GB:   Set swap = 8GB or less

EOF
}

main() {
    # Parse arguments
    if [ "$1" = "-h" ] || [ "$1" = "--help" ]; then
        print_usage
        exit 0
    fi
    
    check_root
    
    # Determine swap size
    local total_ram_mb=$(get_total_ram)
    local total_ram_gb=$((total_ram_mb / 1024))
    
    if [ -n "$1" ]; then
        # User provided size
        SWAP_SIZE_GB=$1
        
        # Validate input is a number
        if ! [[ "$SWAP_SIZE_GB" =~ ^[0-9]+$ ]]; then
            error "Invalid size: $SWAP_SIZE_GB. Please provide a number (GB)"
            print_usage
            exit 1
        fi
    else
        # Default to RAM size
        SWAP_SIZE_GB=$total_ram_gb
        
        # Apply smart defaults
        if [ "$total_ram_gb" -le 2 ]; then
            SWAP_SIZE_GB=$((total_ram_gb * 2))
            info "RAM <= 2GB detected. Setting swap to 2x RAM = ${SWAP_SIZE_GB}GB"
        elif [ "$total_ram_gb" -gt 8 ]; then
            SWAP_SIZE_GB=8
            info "RAM > 8GB detected. Setting swap to 8GB (recommended max)"
        else
            info "Setting swap equal to RAM = ${SWAP_SIZE_GB}GB"
        fi
    fi
    
    # Minimum swap size check
    if [ "$SWAP_SIZE_GB" -lt 1 ]; then
        SWAP_SIZE_GB=1
        warn "Swap size too small, setting to minimum 1GB"
    fi
    
    echo ""
    info "System RAM: ${total_ram_mb}MB (~${total_ram_gb}GB)"
    info "Swap size to create: ${SWAP_SIZE_GB}GB"
    echo ""
    
    # Execute setup
    check_existing_swap
    check_disk_space $((SWAP_SIZE_GB * 1024))
    remove_existing_swapfile
    create_swap_file "$SWAP_SIZE_GB"
    setup_swap
    make_permanent
    
    # Optimize for server (low swappiness)
    configure_swappiness 10
    configure_cache_pressure 50
    
    show_status
    
    echo ""
    log "Swap file setup completed successfully!"
    warn "Note: For SSD storage, consider using zRAM instead of swap file"
    info "Backup of /etc/fstab saved with timestamp"
}

main "$@"
