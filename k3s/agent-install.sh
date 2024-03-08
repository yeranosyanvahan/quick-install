#!/bin/bash

set -a  
source ".env"
set +a 

curl -sfL https://get.k3s.io | INSTALL_K3S_VERSION=${K3S_VERSION} K3S_URL=${K3S_AGENT_URL} K3S_TOKEN=${K3S_AGENT_TOKEN} sh -
curl -fsSL -o get_helm.sh https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3
bash ./get_helm.sh
export KUBECONFIG=${K3S_KUBECONFIG_PATH}
