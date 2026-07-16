#!/bin/bash
set -e

echo "==> Setting up swap..."
fallocate -l 2G /swapfile
chmod 600 /swapfile
mkswap /swapfile
swapon /swapfile
echo '/swapfile none swap sw 0 0' >> /etc/fstab

echo "==> Installing dependencies..."
apt-get update && apt-get upgrade -y
apt-get install -y curl

echo "==> Installing K3s in server mode..."
curl -sfL https://get.k3s.io | INSTALL_K3S_EXEC="--node-ip=192.168.56.110 \
  --node-external-ip=192.168.56.110 \
  --flannel-iface=eth1" sh - || echo "Failed to install K3s server"

echo "==> Waiting for K3s to be ready..."
until kubectl get nodes &>/dev/null; do
  sleep 2
done

echo "==> Deploying applications..."
kubectl apply -f /vagrant/config

echo "==> Done. Node status:"
kubectl get nodes -o wide