# Quick Install

**Quick Install** is a simple Python-based tool designed to manage the installation, configuration, and uninstallation of K3s clusters, along with related tools such as Helm, cert-manager, and Rancher.

## Features

- **Install K3s Server**: Set up a K3s server with customizable Cluster and Service CIDR ranges.
- **Install K3s Agent**: Install a K3s agent by specifying the K3s server URL and token.
- **Install Helm**: Download and install the latest version of Helm to manage Kubernetes packages.
- **Install cert-manager**: Deploy cert-manager to manage TLS certificates within your K3s cluster.
- **Install Rancher**: Deploy Rancher with Let's Encrypt support for Kubernetes cluster management.
- **Edit Versions**: Update versions of Rancher, cert-manager, and K3s directly from the script.
- **Edit CIDRs**: Modify the Cluster and Service CIDRs to suit your networking needs.
- **Uninstall K3s**: Cleanly remove K3s from your system.

## Usage

### Running the Script

1. **Clone the Repository**

   ```bash
   git clone https://github.com/your-username/quick-install.git
   cd quick-install
   ```

2. **Run the Main Script**

   Execute the main Python script to start the tool:

   ```bash
   python3 main.py
   ```

3. **Menu Options**

   Upon running the script, you'll be presented with a menu that allows you to perform various tasks. The available options may vary depending on whether K3s is already installed on your system.

   Here are the main options you might see:

   - **V) Edit/Change Versions**: Allows you to update the versions of Rancher, cert-manager, and K3s. (Make sure they are compatible)
   - **D) Install Dependencies**: Installs required dependencies like `curl`.
   - **A) Install K3s Agent**: Installs K3s agent by specifying the server URL and token.
   - **K) Install K3s Server**: Installs K3s server with the specified version and CIDR ranges.
   - **(K)CIDR) Edit/Change CIDRs**: Modify the Cluster CIDR and Service CIDR.
   - **(K)CNI) Edit/Change CNIs**: Flannel(default), Cilium
   -  **U) Uninstall K3s**: Uninstalls K3s server or agent from your system.
   -  **H) Install Helm**: Installs the latest version of Helm.
   -  **C) Install cert-manager**: Installs cert-manager in your K3s cluster.
   -   **R) Install Rancher**: Installs Rancher with Let's Encrypt support.
   - **E) Exit**: Exits the script.

   After selecting an option, follow the on-screen instructions to complete the task.

## Customization

- **Edit Versions**: You can update the versions of K3s, Rancher, or cert-manager using the "Edit/Change Versions" option in the menu.
- **Modify CIDRs**: Customize the Cluster and Service CIDRs to fit your network setup by selecting the "Edit/Change CIDRs" option.

## Contributing

Contributions are welcome! Feel free to fork the repository, make improvements, and submit a pull request.

## License

This project is open-source and available under the MIT License.
