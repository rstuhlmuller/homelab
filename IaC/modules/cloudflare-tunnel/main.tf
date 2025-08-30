resource "kubernetes_namespace" "cloudflare-tunnel" {
  metadata {
    name = "cloudflare-tunnel"
  }
}

resource "argocd_application" "cloudflare-tunnel" {
  metadata {
    name = "cloudflare-tunnel-ingress-controller"
  }

  spec {
    project = "default"
    destination {
      server    = "https://kubernetes.default.svc"
      namespace = kubernetes_namespace.cloudflare-tunnel.metadata[0].name
    }
    source {
      repo_url        = "https://helm.strrl.dev"
      chart           = "cloudflare-tunnel-ingress-controller"
      target_revision = "0.*"
      helm {
        parameter {
          name  = "image.pullPolicy"
          value = "Always"
        }
        values = yamlencode({
          cloudflare = {
            secretRef = {
              name          = kubernetes_manifest.secret.manifest.metadata.name
              accountIDKey  = "account_id"
              tunnelNameKey = "tunnel_name"
              apiTokenKey   = "api_token"
            }
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
