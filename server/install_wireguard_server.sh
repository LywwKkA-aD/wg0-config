#!/bin/bash
# WireGuard Server Installation Script for Debian 12.10

# Update system packages
apt update && apt upgrade -y

# Install WireGuard and required tools
apt install -y wireguard wireguard-tools qrencode

# Enable IP forwarding
echo "net.ipv4.ip_forward=1" > /etc/sysctl.d/99-wireguard.conf
sysctl -p /etc/sysctl.d/99-wireguard.conf

echo "WireGuard packages successfully installed!"
echo "Next, run the server configuration script."