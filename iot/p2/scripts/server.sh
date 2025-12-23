#!/bin/bash

set -e 

echo "=========================================="
echo "              Part 2 Setup"
echo "=========================================="


echo "[1/4] Installing K3s..."
curl -sfL https://get.k3s.io | sh -s - \
  --write-kubeconfig-mode 644 \
  --node-name hed-dyb

echo "[2/4] Waiting for K3s..."
sleep 20

echo "[3/4] Waiting for Traefik..."
until kubectl get deployment traefik -n kube-system &>/dev/null; do
  sleep 5
done
kubectl wait --namespace kube-system \
  --for=condition=ready pod \
  --selector=app.kubernetes.io/name=traefik \
  --timeout=180s

echo "[4/4] Deploying applications..."
kubectl apply -f /vagrant/confs/deployment.yaml
kubectl apply -f /vagrant/confs/ingress.yaml


kubectl wait --for=condition=available --timeout=180s \
  deployment/app1-deployment \
  deployment/app2-deployment \
  deployment/app3-deployment

echo "=========================================="
echo "✅ Setup complete!"
echo "=========================================="



