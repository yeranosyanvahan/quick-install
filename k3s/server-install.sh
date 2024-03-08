#!/bin/bash

set -a  
source ".env"
set +a 

curl -sfL https://get.k3s.io | INSTALL_K3S_VERSION=${K3S_VERSION} sh -s - server --cluster-cidr=${K3S_SERVER_CIDR}
curl -fsSL -o get_helm.sh https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3
bash ./get_helm.sh
