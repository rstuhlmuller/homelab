resource "kubernetes_namespace" "homarr" {
  metadata {
    name = "homarr"
  }
}

resource "argocd_application" "homarr" {
  metadata {
    name = "homarr"
  }

  spec {
    project = "default"
    destination {
      server    = "https://kubernetes.default.svc"
      namespace = kubernetes_namespace.homarr.metadata[0].name
    }

    source {
      repo_url        = "https://homarr-labs.github.io/charts/"
      chart           = "homarr"
      target_revision = "3.13.0"
      helm {
        parameter {
          name  = "image.tag"
          value = "latest"
        }
        parameter {
          name  = "mysql.internal"
          value = "true"
        }
        parameter {
          name  = "rbac.enabled"
          value = "true"
        }
        parameter {
          name  = "database.migrationEnabled"
          value = "false"
        }
        values = yamlencode({
          ingress = {
            enabled          = true
            ingressClassName = "traefik"
            hosts = [{
              host = "homarr.stinkyboi.com"
              paths = [{
                path = "/"
              }]
            }]
            tls = [{
              secretName = kubernetes_manifest.homarr_certificate.manifest.spec.secretName
              hosts      = ["homarr.stinkyboi.com"]
            }]
          }
          persistence = {
            homarrDatabase = {
              enabled          = true
              storageClassName = "nfs-client"
            }
            homarrImages = {
              enabled          = true
              storageClassName = "nfs-client"
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

resource "kubernetes_manifest" "homarr_certificate" {
  manifest = {
    apiVersion = "cert-manager.io/v1"
    kind       = "Certificate"
    metadata = {
      name      = "homarr-ingressroute-certificate"
      namespace = "homarr"
    }
    spec = {
      secretName = "homarr-certificate-secret"
      issuerRef = {
        name = "cloudflare-clusterissuer"
        kind = "ClusterIssuer"
      }
      dnsNames = [
        "homarr.stinkyboi.com"
      ]
    }
  }
}
