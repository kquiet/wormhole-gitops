#!/bin/bash

helm repo add opensearch-operator https://opensearch-project.github.io/opensearch-k8s-operator/  --force-update

helm install opensearch-operator opensearch-operator/opensearch-operator \
  --namespace devops \
  --create-namespace \
  --version 2.7.0
