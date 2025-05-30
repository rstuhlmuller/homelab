# Homelab Infrastructure as Code (IaC) 🏡💻

Welcome to the **Homelab Infrastructure as Code (IaC)** repository! This project is designed to manage and deploy a Kubernetes-based homelab environment using Terraform, Terragrunt, Helm, and Kubernetes. 🚀

## Hardware 🖥️

- **Control Plane Node:** Acer N4640G running Talos as the Kubernetes control plane
- **Worker Nodes:** Two ZimaBoard 832 (with a third to be added soon)

## Table of Contents 📚

- [Overview](#overview)
- [Hardware](#hardware)
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
- **Modular Design**: Reusable modules for common components like Longhorn, MetalLB, Traefik, cert-manager, monitoring, Tailscale, Technitium, and more.
- **Terragrunt**: Simplify Terraform configurations and manage remote state.
- **AWS S3 Backend**: Store Terraform state securely in an S3 bucket.
- **Pre-commit Hooks**: Ensure code quality with pre-commit checks for Terraform and YAML files.
- **ArgoCD Integration**: Seamlessly manage GitOps workflows for continuous deployment.
- **Certificate Management**: Automated issuance and renewal of TLS certificates with cert-manager.
- **Monitoring Stack**: Comprehensive monitoring and alerting setup with Prometheus, Grafana, and Loki.

## Folder Structure 🗂️

```
IaC/
├── common.yml                # Common configuration variables
├── root.hcl                  # Root Terragrunt configuration
├── _envcommon/               # Shared environment configurations
│   ├── providers/            # Provider configurations (Helm, Kubernetes, etc.)
│   ├── locks/                # Terraform lock files for modules
│   ├── argocd.hcl            # ArgoCD module configuration
│   ├── cert-manager.hcl      # cert-manager module configuration
│   ├── longhorn.hcl          # Longhorn module configuration
│   ├── metallb.hcl           # MetalLB module configuration
│   ├── monitoring.hcl        # Monitoring module configuration
│   ├── open-webui.hcl        # Open WebUI module configuration
│   ├── tailscale.hcl         # Tailscale module configuration
│   ├── technitium.hcl        # Technitium DNS module configuration
│   └── traefik.hcl           # Traefik module configuration
├── modules/                  # Terraform modules for various components
│   ├── argocd/               # ArgoCD module
│   ├── cert-manager/         # cert-manager module
│   ├── longhorn/             # Longhorn module
│   ├── metallb/              # MetalLB module
│   ├── monitoring/           # Monitoring module
│   ├── open-webui/           # Open WebUI module
│   ├── tailscale/            # Tailscale module
│   ├── technitium/           # Technitium DNS module
│   └── traefik/              # Traefik module
└── production/               # Production environment configurations
    ├── account.hcl           # Account-specific variables
    ├── homelab/              # Homelab-specific configurations
        ├── region.hcl        # Region-specific variables
        ├── argocd/           # ArgoCD deployment
        ├── cert-manager/     # cert-manager deployment
        ├── longhorn/         # Longhorn deployment
        ├── metallb/          # MetalLB deployment
        ├── monitoring/       # Monitoring deployment
        ├── open-webui/       # Open WebUI deployment
        ├── tailscale/        # Tailscale deployment
        ├── technitium/       # Technitium DNS deployment
        └── traefik/          # Traefik deployment
proxmox-config/               # Proxmox-specific configurations
tailscale/                    # Tailscale connector YAML
technitium-dns/               # Technitium DNS Helm chart
cert-manager/                 # cert-manager manifests
homeassistant/                # Home Assistant module
external-secrets/             # External Secrets Operator module
descheduler/                  # Kubernetes Descheduler module
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

### cert-manager 🔒
- Automated management and issuance of TLS certificates for Kubernetes.

### Longhorn 🐂
- Distributed block storage for Kubernetes.

### MetalLB 🌐
- Load balancer for bare-metal Kubernetes clusters.

### Monitoring 📈
- Monitoring stack for observability (Prometheus, Grafana, etc.).

### Open WebUI 🌐
- Web-based user interface for managing applications.

### Tailscale 🦎
- Zero-config VPN for secure networking between nodes and remote access.

### Technitium DNS 🧩
- Self-hosted DNS server for your homelab.

### Traefik 🚦
- Reverse proxy and load balancer for Kubernetes.

### Home Assistant 🏠
- Home automation platform to control smart home devices.

### External Secrets 🔑
- Integrate external secret management systems with Kubernetes.

### Descheduler 🔄
- Kubernetes Descheduler for rescheduling pods based on custom policies.

## Contributing 🤝

Contributions are welcome! Please follow these steps:

1. Fork the repository.
2. Create a new branch for your feature or bugfix.
3. Submit a pull request with a detailed description of your changes.

## License 📜

This project is licensed under the MIT License. See the [LICENSE](LICENSE) file for details.

---

Happy Homelabbing! 🏡💻
