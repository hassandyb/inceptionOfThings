

#!/bin/bash

set -e

echo "=========================================="
echo "  P2 Server Setup Started"
echo "=========================================="

# Step 1: Update system
echo "[1/5] Updating system packages..."
export DEBIAN_FRONTEND=noninteractive
sudo apt-get update -qq > /dev/null 2>&1

# Step 2: Install K3s
echo "[2/5] Installing K3s server..."
curl -sfL https://get.k3s.io | sh -s - \
  --write-kubeconfig-mode 644 \
  --node-name hed-dybS

# Step 3: Wait for K3s to be ready
echo "[3/5] Waiting for K3s to be ready..."
sleep 15

# Step 4: Wait for Traefik (Ingress controller) to be ready
echo "[4/5] Waiting for Traefik Ingress controller..."

# First, wait for Traefik deployment to exist
echo "Waiting for Traefik deployment to be created..."
until kubectl get deployment traefik -n kube-system &>/dev/null; do
  echo "  Still waiting for Traefik deployment..."
  sleep 5
done

# Now wait for Traefik pods to be ready
echo "Traefik deployment found, waiting for pods..."
kubectl wait --namespace kube-system \
  --for=condition=ready pod \
  --selector=app.kubernetes.io/name=traefik \
  --timeout=180s

# Step 5: Deploy applications
echo "[5/5] Deploying applications..."
kubectl apply -f /vagrant/confs/deployment.yaml

# Wait for deployments to be ready
echo "Waiting for all deployments to be ready..."
kubectl wait --for=condition=available --timeout=180s \
  deployment/app1-deployment \
  deployment/app2-deployment \
  deployment/app3-deployment

echo "=========================================="
echo "✅ P2 Server setup complete!"
echo "=========================================="

# Show status
echo ""
echo "📊 Cluster Status:"
kubectl get nodes
echo ""
echo "📦 Deployments:"
kubectl get deployments
echo ""
echo "🌐 Services:"
kubectl get services
echo ""
echo "🔀 Ingress:"
kubectl get ingress
echo ""
echo "📍 Pods:"
kubectl get pods -o wide