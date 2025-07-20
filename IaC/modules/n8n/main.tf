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
      target_revision = "1.0.10" # test
      helm {
        values = yamlencode({
          main = {
            config = {
              n8n_host     = "n8n.stinkyboi.com"
              n8n_protocol = "https"
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
