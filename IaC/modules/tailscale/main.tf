resource "kubernetes_namespace" "tailscale" {
  metadata {
    name = "tailscale"
    labels = {
      "pod-security.kubernetes.io/enforce" = "privileged"
      "pod-security.kubernetes.io/audit"   = "privileged"
      "pod-security.kubernetes.io/warn"    = "privileged"
    }
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
      repo_url        = "https://pkgs.tailscale.com/helmcharts"
      chart           = "tailscale-operator"
      target_revision = "1.*"
      helm {
        parameter {
          name  = "image.pullPolicy"
          value = "Always"
        }
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

resource "kubernetes_manifest" "tailscale_connector" {
  manifest = {
    apiVersion = "tailscale.com/v1alpha1"
    kind       = "Connector"
    metadata = {
      name = "exit-node"
    }
    spec = {
      hostname = "homelab-vpn"
      exitNode = true
      subnetRouter = {
        advertiseRoutes = [
          "10.1.0.0/24"
        ]
      }
    }
  }
  depends_on = [argocd_application.tailscale]
}
