resource "kubernetes_namespace_v1" "cert_manager" {
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
      namespace = kubernetes_namespace_v1.cert_manager.metadata[0].name
    }

    source {
      repo_url        = "https://charts.jetstack.io"
      chart           = "cert-manager"
      target_revision = "v1.19.2"

      helm {
        parameter {
          name  = "image.pullPolicy"
          value = "Always"
        }
        value_files = ["values.yaml"]
        values = yamlencode({
          prometheus = {
            enabled = true
            servicemonitor = {
              enabled            = true
              prometheusInstance = "prometheus"
            }
          }
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
