#!/bin/bash
# WireGuard Server Configuration Script for Debian 12.10

# Check if script is run as root
if [ "$(id -u)" -ne 0 ]; then
    echo "This script must be run as root" >&2
    exit 1
fi

# Define variables
SERVER_IP=$(ip -4 addr | grep -oP '(?<=inet\s)\d+(\.\d+){3}' | grep -v "127.0.0.1" | head -n 1)
SERVER_PUBLIC_IP=$(curl -s https://ipinfo.io/ip)
SERVER_PORT=51820
SERVER_WG_NIC="wg0"
SERVER_WG_IPV4="10.0.0.1/24"
WG_CONFIG_DIR="/etc/wireguard"

# Generate server private and public keys
umask 077
SERVER_PRIVKEY=$(wg genkey)
SERVER_PUBKEY=$(echo "$SERVER_PRIVKEY" | wg pubkey)

# Create server configuration file
cat > "$WG_CONFIG_DIR/$SERVER_WG_NIC.conf" << EOF
[Interface]
Address = $SERVER_WG_IPV4
ListenPort = $SERVER_PORT
PrivateKey = $SERVER_PRIVKEY
PostUp = iptables -A FORWARD -i $SERVER_WG_NIC -j ACCEPT; iptables -t nat -A POSTROUTING -o eth0 -j MASQUERADE
PostDown = iptables -D FORWARD -i $SERVER_WG_NIC -j ACCEPT; iptables -t nat -D POSTROUTING -o eth0 -j MASQUERADE

# Clients will be added below by the add client script
EOF

# Change ownership and permission
chmod 600 "$WG_CONFIG_DIR/$SERVER_WG_NIC.conf"

# Enable and start WireGuard service
systemctl enable wg-quick@$SERVER_WG_NIC
systemctl start wg-quick@$SERVER_WG_NIC

echo "WireGuard server has been configured!"
echo "Server Public Key: $SERVER_PUBKEY"
echo "Server IP: $SERVER_PUBLIC_IP"
echo "Server Port: $SERVER_PORT"
echo "Server Interface: $SERVER_WG_NIC"
echo "Server VPN IP: ${SERVER_WG_IPV4%/*}"

# Create directory for client configurations
mkdir -p /etc/wireguard/clients

echo "Now you can run the add_client.sh script to create client configurations."