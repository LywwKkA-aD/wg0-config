#!/bin/bash
# WireGuard Client Configuration Script for Debian 12.10

# Check if script is run as root
if [ "$(id -u)" -ne 0 ]; then
    echo "This script must be run as root" >&2
    exit 1
fi

# Check if WireGuard is installed
if ! command -v wg &> /dev/null; then
    echo "WireGuard is not installed. Please run the installation script first." >&2
    exit 1
fi

# Function to apply configuration
apply_config() {
    local config_file="$1"
    local config_name=$(basename "$config_file" .conf)
    
    # Copy config to WireGuard directory
    cp "$config_file" "/etc/wireguard/$config_name.conf"
    chmod 600 "/etc/wireguard/$config_name.conf"
    
    # Enable and start the service
    systemctl enable wg-quick@$config_name
    systemctl start wg-quick@$config_name
    
    echo "WireGuard configuration $config_name has been applied and service started."
    echo "Check connection with: wg show"
}

# If a configuration file is provided as argument
if [ -n "$1" ]; then
    if [ -f "$1" ]; then
        apply_config "$1"
    else
        echo "Configuration file $1 not found!" >&2
        exit 1
    fi
else
    # If no argument, prompt user
    read -p "Enter the path to your WireGuard configuration file: " CONFIG_FILE
    
    if [ -f "$CONFIG_FILE" ]; then
        apply_config "$CONFIG_FILE"
    else
        echo "Configuration file not found!" >&2
        exit 1
    fi
fi