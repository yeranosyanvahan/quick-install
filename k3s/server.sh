INSTALL_K3S_VERSION=v1.26.12+k3s1
curl -sfL https://get.k3s.io | INSTALL_K3S_VERSION=${INSTALL_K3S_VERSION} sh -s - server --cluster-cidr=172.16.0.0/16 # up to 172.31.0.0/16
curl -fsSL -o get_helm.sh https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3
bash ./get_helm.sh
export KUBECONFIG=/etc/rancher/k3s/k3s.yaml
# /usr/local/bin/k3s-uninstall.sh