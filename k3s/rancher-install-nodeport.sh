#!/bin/bash

set -a  
source ".env"
set +a 

HELMCOMMAND=install
export KUBECONFIG=${K3S_KUBECONFIG_PATH}

helm repo add rancher-stable https://releases.rancher.com/server-charts/stable
helm repo add jetstack https://charts.jetstack.io
helm repo update

kubectl apply -f https://github.com/cert-manager/cert-manager/releases/download/${CERT_MANAGER_VERSION}/cert-manager.crds.yaml

helm ${HELMCOMMAND} cert-manager jetstack/cert-manager \
  --namespace cert-manager \
  --create-namespace \
  --version ${CERT_MANAGER_VERSION}


kubectl create namespace cattle-system

helm ${HELMCOMMAND} rancher rancher-stable/rancher \
  --namespace cattle-system \
  --version=${RANCHER_VERSION} \
  --set bootstrapPassword=${BOOTSTRAP_PASSWORD} \
  --set service.type=NodePort \
  --set service.nodePorts.http=${RANCHER_HTTP_PORT} \
  --set service.nodePorts.https=${RANCHER_HTTPS_PORT}