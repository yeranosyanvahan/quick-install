
# K3s and Rancher Installation Scripts

This repository contains scripts to automate the installation of K3s and Rancher, along with necessary components like Cert Manager. These scripts are designed to work with environment variables defined in a `.env` file to allow for easy customization based on your specific needs.


## Installation / Usage

```bash
# Install curl and git
sudo apt-get update
sudo apt-get install curl git -y

# Clone the repository (Replace <repository-url> with the actual URL of your Git repository)
git clone https://github.com/yeranosyanvahan/quick-install
cd quick-install/k3s

# Update the .env file with your specific configuration
# Use a text editor of your choice, for example, nano or vim
nano .env

# Execute the script to install the K3s server
./server-install.sh

```
## .env File

The `.env` file in the `k3s` directory defines all the necessary environment variables for the scripts. It includes configurations for K3s version, server CIDR, agent settings, Rancher hostname, version, bootstrap password, Cert Manager version, and Let's Encrypt email. Here's a breakdown of what each variable means:

- `K3S_VERSION`: The version of K3s to install. Supports `v1.28.7+k3s1` (latest stable) and `v1.27.11+k3s1` (latest supported by Rancher 2.8.2).
- `K3S_KUBECONFIG_PATH`: Path to the K3s kubeconfig file.
- `K3S_SERVER_CIDR`: CIDR range for the K3s server.
- `K3S_AGENT_URL`: URL for the K3s agent to connect to the server.
- `K3S_AGENT_TOKEN`: Token for the K3s agent to authenticate with the server.
- `RANCHER_HOSTNAME`: Hostname for the Rancher installation.
- `RANCHER_VERSION`: Version of Rancher to install. Example: `2.8.2`.
- `RANCHER_BOOTSTRAP_PASSWORD`: Password to use for bootstrapping Rancher.
- `CERT_MANAGER_VERSION`: Version of Cert Manager to install.
- `LETSENCRYPT_EMAIL`: Email address to use for Let's Encrypt registration.

### Version Compatibility

- For the latest information on version compatibility between K3s and Rancher, refer to the [Latest Rancher version Support Matrix](https://www.suse.com/suse-rancher/support-matrix).
- For the latest information on latest K3s release version follow [this link](https://update.k3s.io/v1-release/channels/stable)
- For other versions of K3s follow [this link](https://docs.k3s.io/release-notes/v1.29.X)
- When using `rancher-install.sh` ensure that the `K3S_VERSION` and `RANCHER_VERSION` specified in the `.env` file are compatible with each other.

## Scripts

The `k3s` directory contains several scripts for installing and uninstalling K3s and Rancher:

- `agent-install.sh`: Script to install the K3s agent.
- `agent-uninstall.sh`: Script to uninstall the K3s agent.
- `rancher-install.sh`: Script to install Rancher using Helm.
- `server-install.sh`: Script to install the K3s server.
- `server-uninstall.sh`: Script for uninstalling the K3s server.

## Requirements

- A Linux-based system with Bash shell.
- `curl` and `helm` are required for the scripts to work. These will be installed by the scripts if not present.

## Note

Ensure the `.env` file's sensitive information is secured appropriately and not included in version control.

