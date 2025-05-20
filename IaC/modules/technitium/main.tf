resource "kubernetes_namespace" "technitium" {
  metadata {
    name = "technitium"
    labels = {
      "pod-security.kubernetes.io/enforce" = "privileged"
    }
  }
}

resource "argocd_application" "technitium" {
  metadata {
    name = "technitium"
  }

  spec {
    project = "default"
    destination {
      server    = "https://kubernetes.default.svc"
      namespace = kubernetes_namespace.technitium.metadata[0].name
    }

    source {
      repo_url = "https://github.com/rstuhlmuller/homelab.git"
      path     = "technitium-dns"

      helm {
        parameter {
          name  = "replicaCount"
          value = "2"
        }
        parameter {
          name  = "controller.namespace"
          value = kubernetes_namespace.technitium.metadata[0].name
        }
        parameter {
          name  = "image.tag"
          value = "13.6.0"
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
