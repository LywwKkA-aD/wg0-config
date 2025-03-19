# WireGuard VPN Client Setup for Debian 12.10

## Description

This guide provides scripts to automate the installation and configuration of a WireGuard VPN client on Debian 12.10. These scripts help you set up, configure, and manage the WireGuard VPN client efficiently.

## Features

- **Automated Installation**: Easily install WireGuard VPN with a single script.
- **Client Configuration**: Apply client configurations effortlessly.

## Prerequisites

Before you begin, ensure you have met the following requirements:

- You have installed Debian 12.10 or a compatible operating system.
- You have sudo privileges.

## Installation

To install the necessary packages, follow these steps:

1. Update your package list and upgrade existing packages:

    ```bash
    sudo apt update && sudo apt upgrade -y
    ```

2. Install required packages:

    ```bash
    sudo apt install nano vim curl -y
    ```

3. Clone the repository:

    ```bash
    git clone https://github.com/LywwKkA-aD/wg0-config.git
    ```

4. Navigate to the client directory:

    ```bash
    cd wg0-config/client
    ```

5. Run the client installation script:

    ```bash
    sudo ./install_wireguard_client.sh
    ```

## Configuration

To configure the WireGuard client, follow these steps:

1. Apply the client configuration (transfer the config from the server):

    ```bash
    sudo ./configure_wireguard_client.sh /path/to/client1.conf
    ```

## Usage

To start the WireGuard VPN:

1. On the client, start the WireGuard interface:

    ```bash
    sudo systemctl start wg-quick@client1
    ```

2. Check the connection status:

    ```bash
    sudo wg show
    ```


## Contributing

To contribute to this project, follow these steps:

1. Fork the repository.
2. Create a new branch: `git checkout -b feature-branch`.
3. Make your changes and commit them: `git commit -m 'Add some feature'`.
4. Push to the branch: `git push origin feature-branch`.
5. Create a pull request.

## License

This project is licensed under the [MIT License](../LICENSE).

## Contact

If you want to contact me, you can reach me at [admin@infralab.cloud](MAIL).