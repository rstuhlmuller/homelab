# Homelab Infrastructure as Code (IaC) 🏡💻

Welcome to the **Homelab Infrastructure as Code (IaC)** repository! This project is designed to manage and deploy a Kubernetes-based homelab environment using Terraform, Terragrunt, Helm, and Kubernetes. 🚀

## Table of Contents 📚

- [Overview](#overview)
- [Features](#features)
- [Folder Structure](#folder-structure)
- [Getting Started](#getting-started)
- [Tools and Technologies](#tools-and-technologies)
- [Modules](#modules)
- [Contributing](#contributing)
- [License](#license)

## Overview 🌟

This repository provides a modular and reusable setup for managing a Kubernetes-based homelab. It leverages the power of Terraform and Terragrunt to define infrastructure as code, making it easy to deploy, manage, and scale your homelab environment. 🛠️

## Features ✨

- **Kubernetes Management**: Deploy and manage Kubernetes resources with ease.
- **Helm Integration**: Use Helm charts for application deployment.
- **Modular Design**: Reusable modules for common components like Longhorn, MetalLB, Traefik, and more.
- **Terragrunt**: Simplify Terraform configurations and manage remote state.
- **AWS S3 Backend**: Store Terraform state securely in an S3 bucket.
- **Pre-commit Hooks**: Ensure code quality with pre-commit checks for Terraform and YAML files.

## Folder Structure 🗂️

```
IaC/
├── common.yml                # Common configuration variables
├── root.hcl                  # Root Terragrunt configuration
├── _envcommon/               # Shared environment configurations
│   ├── providers/            # Provider configurations (Helm, Kubernetes, etc.)
│   ├── locks/                # Terraform lock files for modules
│   ├── argocd.hcl            # ArgoCD module configuration
│   ├── longhorn.hcl          # Longhorn module configuration
│   ├── metallb.hcl           # MetalLB module configuration
│   ├── open-webui.hcl        # Open WebUI module configuration
│   └── traefik.hcl           # Traefik module configuration
├── modules/                  # Terraform modules for various components
│   ├── argocd/               # ArgoCD module
│   ├── longhorn/             # Longhorn module
│   ├── metallb/              # MetalLB module
│   ├── open-webui/           # Open WebUI module
│   └── traefik/              # Traefik module
└── production/               # Production environment configurations
    ├── account.hcl           # Account-specific variables
    ├── homelab/              # Homelab-specific configurations
        ├── region.hcl        # Region-specific variables
        ├── argocd/           # ArgoCD deployment
        ├── longhorn/         # Longhorn deployment
        ├── metallb/          # MetalLB deployment
        ├── open-webui/       # Open WebUI deployment
        └── traefik/          # Traefik deployment
proxmox-config/               # Proxmox-specific configurations
```

## Getting Started 🚀

### Prerequisites 🛠️

Ensure you have the following tools installed:

- [Terraform](https://www.terraform.io/)
- [Terragrunt](https://terragrunt.gruntwork.io/)
- [kubectl](https://kubernetes.io/docs/tasks/tools/)
- [Helm](https://helm.sh/)
- [AWS CLI](https://aws.amazon.com/cli/)

### Steps 📝

1. Clone the repository:
   ```bash
   git clone https://github.com/your-username/homelab.git
   cd homelab
   ```

2. Initialize Terragrunt:
   ```bash
   terragrunt init
   ```

3. Plan and apply changes:
   ```bash
   terragrunt plan
   terragrunt apply
   ```

4. Access your Kubernetes cluster and deployed applications! 🎉

## Tools and Technologies 🛠️

This project uses the following tools and technologies:

- **Terraform**: Infrastructure as Code (IaC) tool for managing cloud resources.
- **Terragrunt**: Wrapper for Terraform to simplify configurations.
- **Helm**: Kubernetes package manager for deploying applications.
- **Kubernetes**: Container orchestration platform.
- **AWS S3**: Remote state storage for Terraform.

## Modules 📦

### ArgoCD 🎯
- Deploy and manage GitOps workflows.

### Longhorn 🐂
- Distributed block storage for Kubernetes.

### MetalLB 🌐
- Load balancer for bare-metal Kubernetes clusters.

### Open WebUI 🌐
- Web-based user interface for managing applications.

### Traefik 🚦
- Reverse proxy and load balancer for Kubernetes.

## Contributing 🤝

Contributions are welcome! Please follow these steps:

1. Fork the repository.
2. Create a new branch for your feature or bugfix.
3. Submit a pull request with a detailed description of your changes.

## License 📜

This project is licensed under the MIT License. See the [LICENSE](LICENSE) file for details.

---

Happy Homelabbing! 🏡💻
