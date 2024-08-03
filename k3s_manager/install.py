import os
from k3s_manager.config import K3S_VERSION, CNI_OPTION

def install_dependencies():
    print("Installing curl...")
    os.system("sudo apt-get install curl")
    print("Dependencies installed successfully.")


def install_k3s_server():
    print("Preparing to install k3s server...")
    cluster_cidr = input("Enter Cluster CIDR (default: 10.42.0.0/16): ") or "10.42.0.0/16"
    service_cidr = input("Enter Service CIDR (default: 10.43.0.0/16): ") or "10.43.0.0/16"
    confirm = input(f"Please confirm the installation with CNI {CNI_OPTION} (Y/N): ").lower()

    if confirm == 'y':
        cni_flag = "--flannel-backend=none" if CNI_OPTION == "cilium" else ""
        os.system(f"curl -sfL https://get.k3s.io | INSTALL_K3S_VERSION={K3S_VERSION} sh -s - server {cni_flag} --cluster-cidr={cluster_cidr} --service-cidr={service_cidr}")
        os.environ["KUBECONFIG"] = "/etc/rancher/k3s/k3s.yaml"
        if CNI_OPTION == "cilium":
            install_cilium()
        print("k3s server installation initiated.")
    else:
        print("k3s server installation cancelled.")


def install_cilium():
    print("Installing Cilium as CNI...")
    os.system("kubectl apply -f https://raw.githubusercontent.com/cilium/cilium/v1.11/install/kubernetes/quick-install.yaml")
    print("Cilium installation completed.")


def install_k3s_agent():
    k3s_agent_url = input("Specify the K3S Server URL: ")
    k3s_agent_token = input("Specify the K3S Server Token: ")

    if k3s_agent_url and k3s_agent_token:
        print("Installing k3s agent...")
        os.system(f"curl -sfL https://get.k3s.io | INSTALL_K3S_VERSION={K3S_VERSION} K3S_URL={k3s_agent_url} K3S_TOKEN={k3s_agent_token} sh -")
        print("k3s agent installation completed.")
    else:
        print("Invalid K3S Server URL or Token. Please try again.")


def install_helm():
    print("Installing Helm...")
    os.system("curl -fsSL -o get_helm.sh https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3")
    os.system("chmod +x get_helm.sh && ./get_helm.sh")
    print("Helm installation completed.")


def install_cert_manager():
    print("Installing cert-manager...")
    os.environ["KUBECONFIG"] = "/etc/rancher/k3s/k3s.yaml"
    os.system("kubectl create namespace cert-manager || true")
    os.system("helm repo add jetstack https://charts.jetstack.io && helm repo update")
    os.system(f"kubectl apply -f https://github.com/cert-manager/cert-manager/releases/download/{CERT_MANAGER_VERSION}/cert-manager.crds.yaml")
    os.system(f"helm install cert-manager jetstack/cert-manager --namespace cert-manager --version {CERT_MANAGER_VERSION}")
    print("cert-manager installation completed.")


def install_rancher():
    rancher_hostname = input("Specify hostname for Rancher to run: ")
    letsencrypt_email = input("Specify Let's Encrypt email: ")

    if rancher_hostname and letsencrypt_email:
        print("Installing Rancher...")
        os.system("helm repo add rancher-stable https://releases.rancher.com/server-charts/stable")
        os.system("kubectl create namespace cattle-system")
        os.system(f"helm install rancher rancher-stable/rancher --namespace cattle-system --version={RANCHER_VERSION} --set hostname={rancher_hostname} --set ingress.tls.source=letsEncrypt --set letsEncrypt.email={letsencrypt_email} --set letsEncrypt.ingress.class=traefik")
        print("Rancher installation completed.")
    else:
        print("Invalid hostname or Let's Encrypt email. Please try again.")


def uninstall_k3s():
    if os.path.exists("/usr/local/bin/k3s-uninstall.sh"):
        os.system("sudo /usr/local/bin/k3s-uninstall.sh")
        print("k3s server uninstalled successfully.")
    elif os.path.exists("/usr/local/bin/k3s-agent-uninstall.sh"):
        os.system("sudo /usr/local/bin/k3s-agent-uninstall.sh")
        print("k3s agent uninstalled successfully.")
    else:
        print("No k3s installation found.")
