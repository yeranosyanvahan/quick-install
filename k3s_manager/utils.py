# k3s_manager/utils.py

import os
from k3s_manager.config import CNI_OPTION

def check_k3s_role():
    if os.system("systemctl is-active --quiet k3s.service") == 0:
        with open("/etc/systemd/system/k3s.service") as f:
            content = f.read()
            if "server" in content:
                return "server"
            elif "agent" in content:
                return "agent"
    return "none"


def edit_rc_versions():
    global RANCHER_VERSION, CERT_MANAGER_VERSION

    new_rancher_version = input(f"Enter new Rancher version (current: {RANCHER_VERSION}): ")
    if new_rancher_version:
        RANCHER_VERSION = new_rancher_version

    new_cert_manager_version = input(f"Enter new Cert-Manager version (current: {CERT_MANAGER_VERSION}): ")
    if new_cert_manager_version:
        CERT_MANAGER_VERSION = new_cert_manager_version


def edit_k3s_version():
    global K3S_VERSION

    new_k3s_version = input(f"Enter new k3s version (current: {K3S_VERSION}): ")
    if new_k3s_version:
        K3S_VERSION = new_k3s_version


def edit_cidrs():
    print("Choose CIDR class and range. Examples: A3/17, B20/16, C0/17.")
    print("Class A: 10.0.0.0 — 10.255.255.255.")
    print("Class B: 172.16.0.0 — 172.31.255.255.")
    print("Class C: 192.168.0.0 — 192.168.255.255.")
    print("Type 'O' for manual input.")

    cidr_choice = input("Enter your choice: ").upper()

    if cidr_choice == 'O':
        cluster_cidr = input("Enter new Cluster CIDR (e.g., 10.42.0.0/16): ")
        service_cidr = input("Enter new Service CIDR (e.g., 10.43.0.0/16): ")
    else:
        print("Unsupported CIDR choice. Manual input required.")
        return

    print(f"New Cluster CIDR: {cluster_cidr}")
    print(f"New Service CIDR: {service_cidr}")


def edit_cni_option():
    global CNI_OPTION

    print("Choose a CNI (Container Network Interface):")
    print("1) Flannel (default)")
    print("2) Cilium")

    choice = input(f"Enter your choice (current: {CNI_OPTION}): ").strip()

    if choice == "1":
        CNI_OPTION = "flannel"
    elif choice == "2":
        CNI_OPTION = "cilium"
    else:
        print("Invalid choice. No changes made.")

    print(f"Current CNI option is now: {CNI_OPTION}")
