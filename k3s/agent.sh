curl -sfL https://get.k3s.io | INSTALL_K3S_VERSION=v1.28.5+k3s1 K3S_URL=https://myserver:6443 K3S_TOKEN=mynodetoken sh -
curl -fsSL -o get_helm.sh https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3
bash ./get_helm.sh
export KUBECONFIG=/etc/rancher/k3s/k3s.yaml