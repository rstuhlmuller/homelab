resource "kubernetes_namespace_v1" "n8n" {
  metadata {
    name = "n8n"
  }
}

resource "argocd_application" "n8n" {
  metadata {
    name = "n8n"
    annotations = {
      "argocd-image-updater.argoproj.io/image-list"          = "n8n=n8nio/n8n:1.x"
      "argocd-image-updater.argoproj.io/n8n.update-strategy" = "semver"
    }
  }

  spec {
    project = "default"
    destination {
      server    = "https://kubernetes.default.svc"
      namespace = kubernetes_namespace_v1.n8n.metadata[0].name
    }

    source {
      repo_url        = "https://github.com/8gears/n8n-helm-chart"
      path            = "charts/n8n"
      target_revision = "1.0.10"
      helm {
        values = yamlencode({
          image = {
            tag = "1.102.4"
          }
          main = {
            persistence = {
              enabled = true
              type    = "dynamic"
              size    = "10Gi"
            }
            config = {
              n8n_runners_enabled = "true"
              n8n_external_url    = "https://n8n.tail67beb.ts.net"
              webhook_url         = "https://n8n.tail67beb.ts.net"
              n8n_host            = "n8n.stinkyboi.com"
              n8n_protocol        = "https"
            }
          }
          ingress = {
            enabled = true
            hosts = [
              {
                host  = "n8n.stinkyboi.com"
                paths = ["/"]
              }
            ]
            tls = [
              {
                secretName = kubernetes_manifest.n8n_tls.manifest.metadata.name
                hosts      = ["n8n.stinkyboi.com"]
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

resource "kubernetes_manifest" "n8n_tls" {
  manifest = {
    apiVersion = "cert-manager.io/v1"
    kind       = "Certificate"
    metadata = {
      name      = "n8n-tls"
      namespace = kubernetes_namespace_v1.n8n.metadata[0].name
    }
    spec = {
      secretName = "n8n-tls"
      issuerRef = {
        name = "cloudflare-clusterissuer"
        kind = "ClusterIssuer"
      }
      dnsNames = [
        "n8n.stinkyboi.com"
      ]
    }
  }
}

resource "kubernetes_ingress_v1" "n8n_tailscale_funnel" {
  metadata {
    name      = "n8n-tailscale-funnel"
    namespace = kubernetes_namespace_v1.n8n.metadata[0].name
    annotations = {
      "tailscale.com/funnel" = "true"
    }
  }
  spec {
    ingress_class_name = "tailscale"
    rule {
      host = "n8n"
      http {
        path {
          path      = "/webhook"
          path_type = "Prefix"
          backend {
            service {
              name = "n8n"
              port {
                number = 80
              }
            }
          }
        }
        path {
          path      = "/webhook-test"
          path_type = "Prefix"
          backend {
            service {
              name = "n8n"
              port {
                number = 80
              }
            }
          }
        }
      }
    }
    tls {
      hosts = ["n8n"]
    }
  }
}
