resource "kubernetes_namespace_v1" "homarr" {
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
      namespace = kubernetes_namespace_v1.homarr.metadata[0].name
    }

    source {
      repo_url        = "https://homarr-labs.github.io/charts/"
      chart           = "homarr"
      target_revision = "8.8.1"
      helm {
        parameter {
          name  = "image.pullPolicy"
          value = "Always"
        }
        parameter {
          name  = "rbac.enabled"
          value = "true"
        }
        parameter {
          name  = "envSecrets.dbEncryption.existingSecret"
          value = kubernetes_manifest.db_secret.manifest.metadata.name
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

resource "kubernetes_manifest" "homarr_image_updater" {
  manifest = {
    apiVersion = "argocd-image-updater.argoproj.io/v1alpha1"
    kind       = "ImageUpdater"
    metadata = {
      name      = "homarr-image-updater"
      namespace = kubernetes_namespace_v1.homarr.metadata[0].name
    }
    spec = {
      namespace = "argocd"
      applicationRefs = [
        {
          namePattern = "homarr"
          images = [
            {
              alias     = "homarr"
              imageName = "ghcr.io/homarr-labs/homarr:latest"
              commonUpdateSettings = {
                updateStrategy = "digest"
              }
            }
          ]
        }
      ]
    }
  }
}
