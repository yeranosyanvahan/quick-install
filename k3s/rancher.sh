CERT_MANAGER_VERSION=v1.12.7
LETSENCRYPT_EMAIL=sample@gmail.com
BOOTSTRAP_PASSWORD=supersecretpassword
RANCHER_HOSTNAME=example.com
RANCHER_VERSION=2.7.9
HELMCOMMAND=install

helm repo add rancher-stable https://releases.rancher.com/server-charts/stable
helm repo add jetstack https://charts.jetstack.io
helm repo update

kubectl apply -f https://github.com/cert-manager/cert-manager/releases/download/${CERT_MANAGER_VERSION}/cert-manager.crds.yaml
kubectl create namespace cattle-system

helm ${HELMCOMMAND} cert-manager jetstack/cert-manager \
  --namespace cert-manager \
  --create-namespace \
  --version ${CERT_MANAGER_VERSION}

helm ${HELMCOMMAND} rancher rancher-stable/rancher \
  --namespace cattle-system \
  --version=${RANCHER_VERSION} \
  --set hostname=${RANCHER_HOSTNAME} \
  --set bootstrapPassword=${BOOTSTRAP_PASSWORD} \
  --set ingress.tls.source=letsEncrypt \
  --set letsEncrypt.email=${LETSENCRYPT_EMAIL} \
  --set letsEncrypt.ingress.class=traefik
  --set service.type=NodePort \
  --set service.nodePorts.http=30080 \
  --set service.nodePorts.https=30433
