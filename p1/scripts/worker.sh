#!/bin/bash
set -e

SERVER_IP="${SERVER_IP:-192.168.56.110}"
WORKER_IP="${WORKER_IP:-192.168.56.111}"
K3S_TOKEN_FILE="/vagrant/scripts/k3s_token"

echo "==> [Worker] Setting up swap..."
fallocate -l 2G /swapfile
chmod 600 /swapfile
mkswap /swapfile
swapon /swapfile
echo '/swapfile none swap sw 0 0' >> /etc/fstab

echo "==> [Worker] Installing dependencies..."
apt-get update -qq
apt-get install -y curl

echo "==> [Worker] Waiting for server token..."
RETRIES=30
until [ -f "${K3S_TOKEN_FILE}" ] && [ -s "${K3S_TOKEN_FILE}" ]; do
  RETRIES=$((RETRIES - 1))
  if [ "$RETRIES" -le 0 ]; then
    echo "ERROR: Server token not found at ${K3S_TOKEN_FILE}. Is the server up?"
    exit 1
  fi
  echo "    Token not ready yet, retrying in 5s... ($RETRIES attempts left)"
  sleep 5
done

K3S_TOKEN=$(cat "${K3S_TOKEN_FILE}")

echo "==> [Worker] Installing K3s in agent mode..."
curl -sfL https://get.k3s.io | \
  K3S_URL="https://${SERVER_IP}:6443" \
  K3S_TOKEN="${K3S_TOKEN}" \
  INSTALL_K3S_EXEC="agent \
    --node-ip=${WORKER_IP} \
    --flannel-iface=eth1" \
  sh -

echo "==> [Worker] K3s agent started and joined the cluster."