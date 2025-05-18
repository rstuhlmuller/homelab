resource "kubernetes_namespace" "tailscale" {
  metadata {
    name = "tailscale"
  }
}

resource "argocd_application" "tailscale" {
  metadata {
    name = "tailscale"
  }

  spec {
    project = "default"
    destination {
      server    = "https://kubernetes.default.svc"
      namespace = kubernetes_namespace.tailscale.metadata[0].name
    }

    source {
      repo_url = "https://github.com/rstuhlmuller/homelab.git"
      path     = "tailscale"

      helm {
        value_files = ["values.yaml"]
      }
    }
    sync_policy {
      automated {
        prune     = true
        self_heal = true
      }
    }
  }
}
