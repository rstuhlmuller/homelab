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
            persistence = {
              enabled = true
              type    = "dynamic"
              size    = "10Gi"
            } // test
            config = {
              n8n_editor_base_url = "https://n8n.stinkyboi.com"
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
      namespace = kubernetes_namespace.n8n.metadata[0].name
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
    namespace = kubernetes_namespace.n8n.metadata[0].name
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
          path      = "/"
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
