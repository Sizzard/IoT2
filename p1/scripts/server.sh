#!/bin/bash
set -e

SERVER_IP="${SERVER_IP:-192.168.56.110}"
K3S_TOKEN_FILE="/vagrant/scripts/k3s_token"

echo "==> [Server] Setting up swap..."
fallocate -l 2G /swapfile
chmod 600 /swapfile
mkswap /swapfile
swapon /swapfile
echo '/swapfile none swap sw 0 0' >> /etc/fstab

echo "==> [Server] Installing dependencies..."
apt-get update -qq
apt-get install -y curl

echo "==> [Server] Installing K3s in controller mode..."

# Install K3s as server, bind to the private network interface
curl -sfL https://get.k3s.io | INSTALL_K3S_EXEC="server \
  --bind-address=${SERVER_IP} \
  --advertise-address=${SERVER_IP} \
  --node-ip=${SERVER_IP} \
  --flannel-iface=eth1" sh -

# Wait until K3s is up
echo "==> [Server] Waiting for K3s to be ready..."
until kubectl get nodes &>/dev/null; do
  sleep 2
done

# Share the node token so the worker can join
echo "==> [Server] Sharing cluster token..."
cp /var/lib/rancher/k3s/server/node-token "${K3S_TOKEN_FILE}"
chmod 644 "${K3S_TOKEN_FILE}"

# Make kubeconfig readable by vagrant user
mkdir -p /home/vagrant/.kube
cp /etc/rancher/k3s/k3s.yaml /home/vagrant/.kube/config
sed -i "s/127.0.0.1/${SERVER_IP}/g" /home/vagrant/.kube/config
chown -R vagrant:vagrant /home/vagrant/.kube

echo "==> [Server] K3s controller ready."
echo "    Node status:"
kubectl get nodes -o wide