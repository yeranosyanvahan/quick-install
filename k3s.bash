#!/bin/bash

# Set environment variables for versions and configurations to their defaults
K3S_VERSION="v1.27.11+k3s1"
RANCHER_VERSION="2.8.2"
CERT_MANAGER_VERSION="v1.14.4"
CLUSTER_CIDR="10.42.0.0/16"  # Default k3s cluster CIDR
SERVICE_CIDR="10.43.0.0/16"  # Default k3s service CIDR
K3S_KUBECONFIG_PATH=/etc/rancher/k3s/k3s.yaml

# Function to check if k3s server or agent is installed
check_k3s_role() {
    if systemctl is-active --quiet k3s.service; then
        # System has k3s service running, check for server or agent role
        if grep -q "server" /etc/systemd/system/k3s.service; then
            echo "server"
        elif grep -q "agent" /etc/systemd/system/k3s.service; then
            echo "agent"
        else
            echo "unknown"
        fi
    else
        echo "none"
    fi
}


#########################################################################################################################################################################################################

install_dependencies() {
    echo "Installing curl..."
    sudo apt-get install curl
    if [ $? -ne 0 ]; then
        echo "Failed to install curl."
        return 1
    fi
    
    echo "Dependencies installed successfully."
}



install_k3s_server() {
    echo "Preparing to install k3s server Version ${K3S_VERSION}..."
    echo "Using Cluster CIDR ${CLUSTER_CIDR} and Service CIDR ${SERVICE_CIDR}."
    read -p "Please confirm the installation (Y/N): " confirm
    if [[ "$confirm" =~ ^[Yy]$ ]]; then
        curl -sfL https://get.k3s.io | INSTALL_K3S_VERSION=${K3S_VERSION} sh -s - server --cluster-cidr=${CLUSTER_CIDR} --service-cidr=${SERVICE_CIDR}
        export KUBECONFIG=${K3S_KUBECONFIG_PATH}
        echo "k3s server installation initiated."
    else
        echo "k3s server installation cancelled."
    fi
}

install_k3s_agent() {
    read -p "Specify the K3S Server URL: " K3S_AGENT_URL
    read -p "Specify the K3S Server Token: " K3S_AGENT_TOKEN

    if [[ ! -z "$K3S_AGENT_URL" ]] && [[ ! -z "$K3S_AGENT_TOKEN" ]]; then
        echo "Installing k3s agent Version ${K3S_VERSION}..."
        curl -sfL https://get.k3s.io | INSTALL_K3S_VERSION=${K3S_VERSION} K3S_URL=${K3S_AGENT_URL} K3S_TOKEN=${K3S_AGENT_TOKEN} sh -
        echo "k3s agent installation completed."
    else
        echo "Invalid K3S Server URL or Token. Please try again."
    fi
}

install_helm() {
    echo "Installing Helm..."
    curl -fsSL -o get_helm.sh https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3
    chmod +x get_helm.sh
    ./get_helm.sh
    echo "Helm installation completed."
}

install_cert_manager() {
    echo "Installing cert-manager Version ${CERT_MANAGER_VERSION}..."
    kubectl create namespace cert-manager || true  # Ignore if namespace already exists
    helm repo add jetstack https://charts.jetstack.io
    helm repo update
    kubectl apply -f https://github.com/cert-manager/cert-manager/releases/download/${CERT_MANAGER_VERSION}/cert-manager.crds.yaml
    helm install cert-manager jetstack/cert-manager --namespace cert-manager --version ${CERT_MANAGER_VERSION}
    echo "cert-manager installation completed."
}

install_rancher() {
    read -p "Specify hostname for Rancher to run: " RANCHER_HOSTNAME
    read -p "Specify Let's Encrypt email: " LETSENCRYPT_EMAIL

    if [[ ! -z "$RANCHER_HOSTNAME" ]] && [[ ! -z "$LETSENCRYPT_EMAIL" ]]; then
        echo "Installing Rancher Version ${RANCHER_VERSION}..."
        helm repo add rancher-stable https://releases.rancher.com/server-charts/stable
        kubectl create namespace cattle-system
        helm install rancher rancher-stable/rancher --namespace cattle-system --version=${RANCHER_VERSION} --set hostname=${RANCHER_HOSTNAME} --set ingress.tls.source=letsEncrypt --set letsEncrypt.email=${LETSENCRYPT_EMAIL} --set letsEncrypt.ingress.class=traefik
        echo "Rancher installation completed."
    else
        echo "Invalid hostname or Let's Encrypt email. Please try again."
    fi
}

# Function to edit Rancher and Cert-manager versions
edit_rc_versions() {
    read -p "Enter new Rancher version (current: $RANCHER_VERSION): " new_rancher_version
    if [[ ! -z "$new_rancher_version" ]]; then
        RANCHER_VERSION=$new_rancher_version
    fi

    read -p "Enter new Cert-Manager version (current: $CERT_MANAGER_VERSION): " new_cert_manager_version
    if [[ ! -z "$new_cert_manager_version" ]]; then
        CERT_MANAGER_VERSION=$new_cert_manager_version
    fi
}

# Function to edit k3s version
edit_k3s_version() {
    read -p "Enter new k3s version (current: $K3S_VERSION): " new_k3s_version
    if [[ ! -z "$new_k3s_version" ]]; then
        K3S_VERSION=$new_k3s_version
    fi
}

edit_cidrs() {
    echo "Choose CIDR class and range. Examples: A3/17, B20/16, C0/17."
    echo "Class A: 10.0.0.0 — 10.255.255.255."
    echo "Class B: 172.16.0.0 — 172.31.255.255."
    echo "Class C: 192.168.0.0 — 192.168.255.255."
    echo "Type 'O' for manual input."
    read -p "Enter your choice: " cidr_choice

    if [[ $cidr_choice =~ ^[Oo]$ ]]; then
        read -p "Enter new Cluster CIDR (e.g., 10.42.0.0/16): " CLUSTER_CIDR
        read -p "Enter new Service CIDR (e.g., 10.43.0.0/16): " SERVICE_CIDR
    elif [[ $cidr_choice =~ ^([A-C])([0-9]+)/(16|17)$ ]]; then
        class=${BASH_REMATCH[1]}
        range=${BASH_REMATCH[2]}
        subnet=${BASH_REMATCH[3]}

        if ! (( (class == "A" && range >= 0 && range <= 255) ||
                (class == "B" && range >= 16 && range <= 31) ||
                (class == "C" && range == 0 && subnet == 17) )); then
            echo "Invalid range for selected class or unsupported subnet for Class C."
            return
        fi

        case $class in
            A) base="10.$range.0.0";;
            B) base="172.$range.0.0";;
            C) base="192.168.0.0";;
        esac

        if [[ $subnet == 17 ]]; then
            CLUSTER_CIDR="$base/17"
            # For Class C, /17 is directly used, as it's the only allowed option.
            if [[ $class == "C" ]]; then
                SERVICE_CIDR="192.168.128.0/17"
            else
                # Adjust the second CIDR for /17 in Classes A and B.
                octet2=$((range + 1))
                if [[ $class == "A" ]]; then
                    SERVICE_CIDR="10.$octet2.128.0/17"
                elif [[ $class == "B" ]]; then
                    SERVICE_CIDR="172.$octet2.128.0/17"
                fi
            fi
        elif [[ $subnet == 16 ]]; then
            CLUSTER_CIDR="$base/16"
            if [[ $class != "C" ]]; then
                # For Class A and B with /16, increment the second octet for SERVICE_CIDR.
                octet2=$((range + 1))
                if [[ $class == "A" ]]; then
                    SERVICE_CIDR="10.$octet2.0.0/16"
                elif [[ $class == "B" ]]; then
                    SERVICE_CIDR="172.$octet2.0.0/16"
                fi
            else
                echo "Class C only supports /17 for this setup."
                return
            fi
        else
            echo "Invalid subnet. Only /16 and /17 are supported."
            return
        fi
    else
        echo "Invalid format. Please enter a valid option."
        return
    fi

    echo "New Cluster CIDR: $CLUSTER_CIDR"
    echo "New Service CIDR: $SERVICE_CIDR"

}

#########################################################################################################################################################################################################

while true; do
    echo "============================================"
    echo " K3s Installation/Uninstallation Tool Menu"
    echo "============================================"
    echo ""
    echo "Here are your options:"
    echo ""

    declare -A actions

    # Adjust options based on k3s role
    K3S_ROLE=$(check_k3s_role)
    if [ "$K3S_ROLE" = "server" ] || [ "$K3S_ROLE" = "agent" ]; then
        INSTALLED_VERSION=$(k3s --version | awk '{print $3}')
        echo "U) Uninstall k3s $K3S_ROLE (the installed version $INSTALLED_VERSION)."
        actions[U]=1
        echo "V) Edit/Change Versions (Rancher, Cert-Manager)."
        actions[V]=1
        echo "H) Install Helm (latest version)."
        actions[H]=1
        echo "C) Install cert-manager Version $CERT_MANAGER_VERSION."
        actions[C]=1
        echo "R) Install Rancher Version $RANCHER_VERSION."
        actions[R]=1
    else
        echo "K) Install k3s-server Version $K3S_VERSION with cluster CIDR $CLUSTER_CIDR and service CIDR $SERVICE_CIDR."
        actions[K]=1
        echo "A) Install k3s-agent Version $K3S_VERSION."
        actions[A]=1
        echo "J) Edit/Change Versions (k3s)."
        actions[J]=1
        echo "I) Edit/Change IP CIDRs (Cluster CIDR, Service CIDR)."
        actions[I]=1
    fi

    echo "D) Install dependencies."
    actions[D]=1
    echo "E) Exit."
    actions[E]=1


    options_string=""

    # Generating options string from actions keys
    for key in "${!actions[@]}"; do
        options_string+="$key, "
    done

    echo ""
    echo "Please enter your choice (e.g. $options_string):"

    read choice
    choice=$(echo "$choice" | tr '[:lower:]' '[:upper:]') # Convert to uppercase

    if [ -z ${actions[$choice]} ]; then
        echo "Invalid choice. Please enter a valid option."
        continue
    fi

    # Switch case for user choice with placeholder functions
    case $choice in
        U)
            if [ "$K3S_ROLE" = "server" ]; then
                sudo /usr/local/bin/k3s-uninstall.sh
            elif [ "$K3S_ROLE" = "agent" ]; then
                sudo /usr/local/bin/k3s-agent-uninstall.sh
            fi
            ;;
        V) edit_rc_versions ;;
        H) install_helm ;;
        C) install_cert_manager ;;
        R) install_rancher ;;
        D) install_dependencies ;;
        K) install_k3s_server ;;
        A) install_k3s_agent ;;
        J) edit_k3s_version ;;
        I) edit_cidrs ;;
        E) echo "Exiting..."; exit 0 ;;
    esac
    echo "Press any key to return to the main menu..."
    read -n 1 -s
done
