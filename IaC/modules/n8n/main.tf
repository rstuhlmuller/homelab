resource "kubernetes_namespace" "n8n" {
  metadata {
    name = "n8n"
  }
}

resource "argocd_application" "n8n" {
  metadata {
    name = "n8n"
  }

  spec {
    project = "default"
    destination {
      server    = "https://kubernetes.default.svc"
      namespace = kubernetes_namespace.n8n.metadata[0].name
    }

    source {
      repo_url        = "https://github.com/8gears/n8n-helm-chart"
      path            = "charts/n8n"
      target_revision = "1.0.10"
      helm {
        values = yamlencode({
          main = {
            config = {
              n8n_host     = "n8n.tail67beb.ts.net"
              n8n_protocol = "https"
            }
          }
          ingress = {
            enabled   = true
            className = "tailscale"
            annotations = {
              "tailscale.com/funnel" = "true"
            }
            hosts = [
              {
                host  = "n8n"
                paths = ["/"]
              }
            ]
            tls = [
              {
                hosts = ["n8n"]
              }
            ]
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
