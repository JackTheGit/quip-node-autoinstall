# Quip Network Node Auto-Installer

A one-click bash script to fully automate the deployment of a Quip Network CPU testnet node on Ubuntu. 

This script handles Docker installation, repository cloning, environment variable configuration, and Docker Compose initialization.

## Requirements
* Fresh Ubuntu 22.04 or 24.04 LTS
* Root privileges

## One-Click Installation
Run the following command on your server to download and execute the script:

\`\`\`bash
wget -O install.sh https://raw.githubusercontent.com/JackTheGit/quip-node-autoinstall/main/install.sh && chmod +x install.sh && sudo ./install.sh
\`\`\`

## Setup Process
The script will prompt you for three variables:
1. **EVM Wallet Address**: Your public 0x address for campaign points.
2. **Validator Nickname**: A recognizable moniker for your node.
3. **CPU Cores**: The number of cores to allocate to the miner.

The script automatically detects your public IP, configures the `.env` and `config.toml` files, and launches the node containers in the background.
