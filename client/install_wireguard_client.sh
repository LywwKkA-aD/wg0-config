#!/bin/bash
# WireGuard Client Installation Script for Debian 12.10

# Check if script is run as root
if [ "$(id -u)" -ne 0 ]; then
    echo "This script must be run as root" >&2
    exit 1
fi

# Update system packages
apt update && apt upgrade -y

# Install WireGuard
apt install -y wireguard wireguard-tools resolvconf

echo "WireGuard client packages successfully installed!"
echo "Now you need to add your client configuration file to /etc/wireguard/"
echo "Example: Place your-config.conf in /etc/wireguard/"
echo "Then run: systemctl enable wg-quick@your-config"
echo "And start it with: systemctl start wg-quick@your-config"