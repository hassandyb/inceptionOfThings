#!/bin/bash

set -e

echo "=========================================="
echo "  Server Setup Started"
echo "=========================================="

# Step 1: Update system
echo "[1/4] Updating system packages..."
export DEBIAN_FRONTEND=noninteractive
sudo apt-get update -qq > /dev/null 2>&1

# Step 2: Install K3s
echo "[2/4] Installing K3s server..."
curl -sfL https://get.k3s.io | sh -s - \
  --write-kubeconfig-mode 644 \
  --node-name hed-dybS

# Step 3: Wait for K3s to be fully ready
echo "[3/4] Waiting for K3s to be ready..."
sleep 10

# Step 4: Export token for worker
echo "[4/4] Exporting join token..."
sudo cat /var/lib/rancher/k3s/server/node-token > /vagrant/token.txt

chmod 644 /vagrant/token.txt

echo "=========================================="
echo "✅ Server setup complete!"
echo "=========================================="

# Show cluster status
kubectl get nodes