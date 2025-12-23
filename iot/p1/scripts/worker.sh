#!/bin/bash

set -e

echo "=========================================="
echo "  Worker Setup Started"
echo "=========================================="

# Step 1: Wait for server
echo "[1/5] Waiting for server to be ready..."
sleep 30

# Step 2: Check for token
echo "[2/5] Checking for join token..."
if [ ! -f /vagrant/token.txt ]; then
  echo "❌ ERROR: Token file not found!"
  exit 1
fi

TOKEN=$(cat /vagrant/token.txt)
echo "✅ Token found!"

# Step 3: Update system
echo "[3/5] Updating system packages..."
export DEBIAN_FRONTEND=noninteractive
sudo apt-get update -qq > /dev/null 2>&1

# Step 4: Install K3s in agent mode
echo "[4/5] Installing K3s agent..."
curl -sfL https://get.k3s.io | K3S_URL=https://192.168.56.110:6443 \
  K3S_TOKEN=$TOKEN \
  sh -s - \
  --node-name hed-dybSW \
  --disable-apiserver-lb # Turns OFF the local load balancer | Forces the worker to talk directly to 192.168.56.110:6443

# Step 5: Wait for agent to start
echo "[5/5] Waiting for agent to connect..."
sleep 10

echo "=========================================="
echo "✅ Worker setup complete!"
echo "=========================================="