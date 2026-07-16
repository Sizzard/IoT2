#!/bin/bash

##### Install K8s and K3d
sudo curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"

sudo chmod +x ./kubectl
sudo mv ./kubectl /usr/local/bin/kubectl

wget -q -O - https://raw.githubusercontent.com/k3d-io/k3d/main/install.sh | bash
#####

k3d cluster create argocd --port "8888:30088@server:0"

kubectl create namespace argocd
kubectl create namespace dev

kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml

kubectl apply -n argocd -f app.yml

# Launching server and expose port for accessing via website:             kubectl port-forward svc/argocd-server -n argocd 8080:443

# Password command:                                                       kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d > password.txt && echo "$(cat password.txt)"

# Connection command:                                                     curl http://localhost:8888