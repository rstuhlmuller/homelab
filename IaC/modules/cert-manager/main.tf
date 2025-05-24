resource "kubernetes_namespace" "cert_manager" {
  metadata {
    name = "cert-manager"
  }
}

resource "argocd_application" "cert_manager" {
  metadata {
    name = "cert-manager"
  }

  spec {
    project = "default"
    destination {
      server    = "https://kubernetes.default.svc"
      namespace = kubernetes_namespace.cert_manager.metadata[0].name
    }

    source {
      repo_url        = "https://charts.jetstack.io"
      chart           = "cert-manager"
      target_revision = "v1.17.2"

      helm {
        value_files = ["values.yaml"]
        values = yamlencode({
          crds = {
            enabled = true
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
