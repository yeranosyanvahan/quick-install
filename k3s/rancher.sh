helm repo add rancher-stable https://releases.rancher.com/server-charts/stable
helm repo add jetstack https://charts.jetstack.io
helm repo update

kubectl apply -f https://github.com/cert-manager/cert-manager/releases/download/v1.7.1/cert-manager.crds.yaml
kubectl create namespace cattle-system

helm install cert-manager jetstack/cert-manager \
  --namespace cert-manager \
  --create-namespace \
  --version v1.12.7

helm install rancher rancher-stable/rancher \
  --namespace cattle-system \
  --set hostname=example.com \
  --set bootstrapPassword=supersecretpassword \
  --set ingress.tls.source=letsEncrypt \
  --set letsEncrypt.email=sample@gmail.com \
  --set letsEncrypt.ingress.class=traefik