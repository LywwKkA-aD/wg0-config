#!/bin/bash
# WireGuard Add Client Script for Debian 12.10

# Check if script is run as root
if [ "$(id -u)" -ne 0 ]; then
    echo "This script must be run as root" >&2
    exit 1
fi

# Define variables
SERVER_WG_NIC="wg0"
SERVER_WG_IPV4="10.0.0.1/24"
CLIENT_DNS="1.1.1.1,1.0.0.1"
WG_CONFIG_DIR="/etc/wireguard"
CLIENTS_DIR="/etc/wireguard/clients"

# Check if WireGuard is installed
if ! command -v wg &> /dev/null; then
    echo "WireGuard is not installed. Please run the installation script first." >&2
    exit 1
fi

# Check if server configuration exists
if [ ! -f "$WG_CONFIG_DIR/$SERVER_WG_NIC.conf" ]; then
    echo "Server configuration not found. Please run the server configuration script first." >&2
    exit 1
fi

# Get server information
SERVER_PUBKEY=$(grep PrivateKey "$WG_CONFIG_DIR/$SERVER_WG_NIC.conf" | cut -d ' ' -f 3 | wg pubkey)
SERVER_PORT=$(grep ListenPort "$WG_CONFIG_DIR/$SERVER_WG_NIC.conf" | cut -d ' ' -f 3)
SERVER_PUBLIC_IP=$(curl -s https://ipinfo.io/ip)

# Function to get next available IP
get_next_ip() {
    local last_ip
    if grep -q '\[Peer\]' "$WG_CONFIG_DIR/$SERVER_WG_NIC.conf"; then
        last_ip=$(grep AllowedIPs "$WG_CONFIG_DIR/$SERVER_WG_NIC.conf" | tail -n1 | cut -d '.' -f 4 | cut -d '/' -f 1)
        echo $((last_ip + 1))
    else
        echo 2
    fi
}

# Get client name
if [ -z "$1" ]; then
    read -p "Enter client name: " CLIENT_NAME
else
    CLIENT_NAME="$1"
fi

# Remove special characters from client name
CLIENT_NAME=$(echo "$CLIENT_NAME" | tr -cd '[:alnum:]._-')

# Check if client already exists
if [ -f "$CLIENTS_DIR/$CLIENT_NAME.conf" ]; then
    echo "Client $CLIENT_NAME already exists!" >&2
    exit 1
fi

# Generate client keys
CLIENT_PRIVKEY=$(wg genkey)
CLIENT_PUBKEY=$(echo "$CLIENT_PRIVKEY" | wg pubkey)

# Get next available IP
CLIENT_IP="10.0.0.$(get_next_ip)/32"

# Update server config
cat >> "$WG_CONFIG_DIR/$SERVER_WG_NIC.conf" << EOF

[Peer]
# $CLIENT_NAME
PublicKey = $CLIENT_PUBKEY
AllowedIPs = $CLIENT_IP
EOF

# Create client config
mkdir -p "$CLIENTS_DIR"
cat > "$CLIENTS_DIR/$CLIENT_NAME.conf" << EOF
[Interface]
PrivateKey = $CLIENT_PRIVKEY
Address = $CLIENT_IP
DNS = $CLIENT_DNS

[Peer]
PublicKey = $SERVER_PUBKEY
Endpoint = $SERVER_PUBLIC_IP:$SERVER_PORT
AllowedIPs = 0.0.0.0/0, ::/0
PersistentKeepalive = 25
EOF

# Restart WireGuard service
wg syncconf "$SERVER_WG_NIC" <(wg-quick strip "$SERVER_WG_NIC")

echo "Client $CLIENT_NAME added successfully!"
echo "Client configuration saved to $CLIENTS_DIR/$CLIENT_NAME.conf"

# Generate QR code for mobile devices
echo "Scan this QR code with your mobile device:"
qrencode -t ansiutf8 < "$CLIENTS_DIR/$CLIENT_NAME.conf"

echo -e "To add this client to your device, you can either:"
echo -e "  1. Scan the QR code above with the WireGuard mobile app"
echo -e "  2. Copy the client configuration file to your device"
echo -e "\nClient configuration file content:"
echo "======================================"
cat "$CLIENTS_DIR/$CLIENT_NAME.conf"
echo "======================================"