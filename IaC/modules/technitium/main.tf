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
        value_files = ["values.yaml"]
        values = yamlencode({
          controller = {
            namespace = kubernetes_namespace.technitium.metadata[0].name
          }
          image = {
            tag = "13.6.0"
          }
        })
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
