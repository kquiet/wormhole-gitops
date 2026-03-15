#!/bin/bash
helm repo add argo https://argoproj.github.io/argo-helm --force-update

kubectl apply -k "https://github.com/argoproj/argo-cd/manifests/crds?ref=v3.0.5"

helm upgrade --install argocd argo/argo-cd \
  --namespace argocd --create-namespace \
  --version 8.0.16 \
  -f values.yaml
