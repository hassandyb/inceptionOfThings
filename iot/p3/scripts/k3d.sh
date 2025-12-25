#!/bin/bash

set -e

echo "======================================"
echo "     Part3: K3d + Argo CD Setup"
echo "======================================"

echo ""
echo "[1/5] installing Docker..."

if command -v docker &> /dev/null; then
    echo "Docker already installed: $(docker --version)"
else

    curl -fsSL https://get.docker.com | sudo sh >/dev/null 
    


    sudo usermod -aG docker $USER
    newgrp docker
    echo "Dokcer installed successfully!"
    echo "Dokcer Version: $(docker --version)"
fi



echo ""
echo "[2/5] Installing kubectl..."


if command -v kubectl &> /dev/null; then
    echo "kubectl already installed: kubectl version : $(kubectl version --client | head -n1)"
else

    sudo snap install kubectl --classic
    echo "kubectl installed successfully!"
    echo "kubectl version : $(kubectl version --client | head -n1)"
fi

echo ""
echo "[3/5] Installing K3d..."

if command -v k3d > /dev/null; then 
    echo "k3d already installed: $(k3d version | head -n1)"
else
    curl -s https://raw.githubusercontent.com/k3d-io/k3d/main/install.sh | sudo bash 
    echo "k3d installed successfully!"
    echo "k3d vesrion: $(k3d version | head -n1)" 
fi









echo ""
echo "[4/5] Creating K3d cluster..."

CLUSTER_NAME="hed-dybS"

# Check if cluster already exists
if k3d cluster list | grep -q "$CLUSTER_NAME"; then
    echo "Cluster '$CLUSTER_NAME' already exists - skipping creation"
    echo "Using existing cluster..."
else
    # Create cluster only if it doesn't exist
    echo "Creating cluster '$CLUSTER_NAME'..."
    k3d cluster create $CLUSTER_NAME
fi

# CRITICAL: Ensure kubeconfig is properly merged and context switched
echo ""
echo "Merging kubeconfig and switching context..."
k3d kubeconfig merge $CLUSTER_NAME -d --overwrite

# Verify we're on the correct context
CURRENT_CONTEXT=$(kubectl config current-context)
echo "Current kubectl context: $CURRENT_CONTEXT"

# If not on the right context, switch explicitly
if [[ "$CURRENT_CONTEXT" != "k3d-$CLUSTER_NAME" ]]; then
    echo "Switching to k3d-$CLUSTER_NAME context..."
    kubectl config use-context "k3d-$CLUSTER_NAME"
fi

echo ""
echo "[5/5] Verifying cluster..."

# Wait for cluster to be ready
echo "Waiting for nodes to be ready..."
sleep 5

# Check nodes (should now show k3d nodes, not host)
kubectl get nodes

# Verify we got the right nodes
NODE_COUNT=$(kubectl get nodes --no-headers | wc -l)
if [[ $NODE_COUNT -eq 0 ]]; then
    echo "ERROR: No nodes found! Context switch failed."
    exit 1
fi

echo ""
echo "============================================"
echo "     K3d Setup Complete!"
echo "============================================"
echo ""
echo "Cluster: $CLUSTER_NAME"
echo "Context: k3d-$CLUSTER_NAME"
echo "Nodes: $NODE_COUNT"
echo ""
echo "Next step: Run argocd.sh to install Argo CD"
echo ""


