#!/bin/bash

set -e

echo "=================================================="
echo "   Quip Network Node One-Click Auto-Installer   "
echo "=================================================="
echo ""

# 1. Check for root privileges
if [ "$EUID" -ne 0 ]; then
  echo "Please run this script as root (use sudo)."
  exit 1
fi

# 2. Collect user inputs
read -p "Enter your EVM Wallet Address (e.g., 0x123...): " WALLET_ADDRESS
read -p "Enter your Validator Nickname (no spaces): " NICKNAME
read -p "How many CPU cores do you want to allocate to mining? " CPU_CORES

# Calculate CPU limit for Docker compose
CPU_MAX=$((CPU_CORES - 1))
CPUSET="0-${CPU_MAX}"
FULL_NODE_NAME="${NICKNAME}-${WALLET_ADDRESS}"

# Fetch the public IP automatically
PUBLIC_IP=$(curl -s ifconfig.me)
echo "Detected Public IP: $PUBLIC_IP"
echo ""

# 3. Install dependencies and Docker
echo "Updating system and installing dependencies..."
apt-get update && apt-get upgrade -y
apt-get install -y curl git nano jq python3

if ! command -v docker &> /dev/null; then
    echo "Docker not found. Installing Docker..."
    curl -fsSL https://get.docker.com -o get-docker.sh
    sh get-docker.sh
    rm get-docker.sh
else
    echo "Docker is already installed."
fi

# 4. Clone repository and setup directories
echo "Cloning Quip node repository..."
if [ -d "quip-node" ]; then
    echo "Directory quip-node already exists. Backing it up to quip-node_backup..."
    mv quip-node quip-node_backup_$(date +%s)
fi

git clone https://gitlab.com/quip.network/nodes.quip.network.git quip-node
cd quip-node
mkdir -p data

# 5. Configure .env file
echo "Configuring environment variables..."
cp env.example .env

sed -i "s/^VALIDATOR_NAME=.*/VALIDATOR_NAME=${FULL_NODE_NAME}/" .env
sed -i "s/^#\?\s*QUIP_MINER_CPUSET=.*/QUIP_MINER_CPUSET=${CPUSET}/" .env

# 6. Configure config.toml
echo "Configuring miner settings..."
cp config/quip-miner.toml data/config.toml

sed -i "s/^public_host = .*/public_host = \"${PUBLIC_IP}\"/" data/config.toml
sed -i "s/^#\?\s*node_name = .*/node_name = \"${FULL_NODE_NAME}\"/" data/config.toml
sed -i "s/^#\?\s*num_cpus = .*/num_cpus = ${CPU_CORES}/" data/config.toml

# 7. Start the node
echo "Pulling Docker images and starting the node..."
docker compose --profile cpu pull
docker compose --profile cpu up -d quip-validator dashboard cpu

echo "=================================================="
echo "Installation Complete!"
echo "Your node '$FULL_NODE_NAME' is now running in the background."
echo "To check your node's status, run:"
echo "curl -fsS http://127.0.0.1:20049/api/v1/status"
echo "=================================================="
