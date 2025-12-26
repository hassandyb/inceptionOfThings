#!/bin/bash

# GREEN="\033[32m"
# RED="\033[31m"
# BLUE="\033[43m"
# RESET="\033[0m"


echo "============================================"
echo "     Installing Argo CD"
echo "============================================"


echo ""

echo "[1/5] Creating namespaces..."

if kubectl get namespace argocd &> /dev/null; then
    echo "Namespace 'argocd' already exists"
else
    kubectl create namespace argocd
    echo "'argocd' namespace Created successfully."
fi


if kubectl get namespace dev &> /dev/null; then
    echo "Namespace 'dev' already exists"
else
    kubectl create namespace dev
    echo "'dev' namespace Created successfully."
fi

# echo ""
# echo "Current namespaces:"
# kubectl get namespaces

echo ""
echo "[2/5] Installing Argo CD..."

if kubectl get deployment argocd-server -n argocd > /dev/null; then
    echo "Argo CD already installed"
    echo "Argo CD pods:"
    kubectl get pods -n argocd

else
    kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml
    echo "Argo CD installed successfully."
    sleep 10
    echo "Argo CD pods:"
    kubectl get pods -n argocd
fi


echo ""
echo "[3/5] adding our domain to /etc/hosts..."

HOST_ENTRY="127.0.0.1 argocd.mydomain.com"
HOSTS_FILE="/etc/hosts"
MY_DOMAIN_NAME="argocd.mydomain.com"

if grep "$MY_DOMAIN_NAME" "$HOSTS_FILE"; then
    echo "Entry Already exists."
else
    sudo bash -c "echo '$HOST_ENTRY' >> /etc/hosts"
    echo "Entry added successfully."
fi



echo ""
echo "[4/5] Getting Argo CD admin password..."

PASSWORD=$(kubectl get secret argocd-initial-admin-secret -n argocd -o jsonpath="{.data.password}" | base64 --decode)

echo ""
echo "============================================"
echo "Argo CD Credentials:"
echo "============================================"
echo "Username: admin"
echo "Password:$PASSWORD"
echo "============================================"




echo ""
echo "[5/5] Start port forwarding..."
sudo pkill -f "port-forward.*8085" &>/dev/null 

kubectl port-forward svc/argocd-server -n argocd 8085:80 > /dev/null &>/dev/null & 

# kubectl port-forward svc/argocd-server -n argocd 8085:443 > /dev/null &>/dev/null & 
echo "Port forwarding started successfully."


echo ""
echo "============================================"
echo "     Argo CD Installation Complete!"
echo "============================================"
echo ""
echo ""
echo "Access Argo CD UI:"
echo "  http://localhost:8085"
echo "  OR"
echo "  https://$MY_DOMAIN_NAME:8085"
echo ""
echo "Login:"
echo "  Username: admin"
echo "  Password: $PASSWORD"
echo ""
