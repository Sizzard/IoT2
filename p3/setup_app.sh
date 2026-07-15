#!/bin/bash

k3d cluster create argocd --port "30088:30088@server:0"

kubectl create namespace argocd
kubectl create namespace dev

kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml

kubectl apply -n argocd -f app.yml

# Launching server and expose port for accessing via website:             kubectl port-forward svc/argocd-server -n argocd 8080:443

# Password command:                                                       kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d > password.txt && echo "$(cat password.txt)"

# Connection command:                                                     curl http://localhost:30088