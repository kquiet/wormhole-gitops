#!/bin/bash

helm repo add external-secrets https://charts.external-secrets.io --force-update

helm install external-secrets external-secrets/external-secrets \
  --namespace external-secrets --create-namespace \
  --version 0.15.1
