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
