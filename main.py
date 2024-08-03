import os
from k3s_manager.install import (
    install_k3s_server,
    install_k3s_agent,
    install_helm,
    install_cert_manager,
    install_rancher,
    uninstall_k3s,
    install_dependencies,
)
from k3s_manager.config import K3S_VERSION, RANCHER_VERSION, CERT_MANAGER_VERSION
from k3s_manager.utils import edit_rc_versions, edit_k3s_version, edit_cidrs, check_k3s_role


def main_menu():
    while True:
        print("============================================")
        print(" K3s Installation/Uninstallation Tool Menu")
        print("============================================")
        print("")
        print("Here are your options:")
        print("")

        actions = {}

        # Adjust options based on k3s role
        k3s_role = check_k3s_role()
        if k3s_role == "server" or k3s_role == "agent":
            installed_version = os.popen("k3s --version").read().split()[2]
            print(f"U) Uninstall k3s {k3s_role} (the installed version {installed_version}).")
            actions['U'] = uninstall_k3s
            print("V) Edit/Change Versions (Rancher, Cert-Manager).")
            actions['V'] = edit_rc_versions
            print("H) Install Helm (latest version).")
            actions['H'] = install_helm
            print(f"C) Install cert-manager Version {CERT_MANAGER_VERSION}.")
            actions['C'] = install_cert_manager
            print(f"R) Install Rancher Version {RANCHER_VERSION}.")
            actions['R'] = install_rancher
        else:
            print(f"K) Install k3s-server Version {K3S_VERSION}.")
            actions['K'] = install_k3s_server
            print(f"A) Install k3s-agent Version {K3S_VERSION}.")
            actions['A'] = install_k3s_agent
            print("J) Edit/Change Versions (k3s).")
            actions['J'] = edit_k3s_version
            print("I) Edit/Change IP CIDRs (Cluster CIDR, Service CIDR).")
            actions['I'] = edit_cidrs

        print("D) Install dependencies.")
        actions['D'] = install_dependencies
        print("E) Exit.")
        actions['E'] = exit_program

        print("")
        choice = input("Please enter your choice: ").upper()

        if choice in actions:
            actions[choice]()
        else:
            print("Invalid choice. Please enter a valid option.")

        input("Press any key to return to the main menu...")


def exit_program():
    print("Exiting...")
    exit(0)


if __name__ == "__main__":
    main_menu()
