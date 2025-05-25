resource "kubernetes_namespace" "media" {
  metadata {
    name = "media"
    labels = {
      "pod-security.kubernetes.io/enforce" = "privileged",
      "pod-security.kubernetes.io/audit"   = "privileged",
      "pod-security.kubernetes.io/warn"    = "privileged"
    }
  }
}


resource "kubernetes_manifest" "media_certificate" {
  manifest = {
    apiVersion = "cert-manager.io/v1"
    kind       = "Certificate"
    metadata = {
      name      = "media-certificate"
      namespace = kubernetes_namespace.media.metadata[0].name
    }
    spec = {
      secretName = "media-certificate-secret"
      issuerRef = {
        name = "cloudflare-clusterissuer"
        kind = "ClusterIssuer"
      }
      dnsNames = [
        "media.stinkyboi.com"
      ]
    }
  }
}

resource "argocd_application" "prometheus" {
  metadata {
    name = "media"
  }

  spec {
    project = "default"
    destination {
      server    = "https://kubernetes.default.svc"
      namespace = kubernetes_namespace.media.metadata[0].name
    }

    source {
      repo_url        = "https://github.com/kubealex/k8s-mediaserver-operator.git"
      path            = "helm-charts/k8s-mediaserver"
      target_revision = "HEAD"
      helm {
        parameter {
          name  = "general.ingress.ingressClassName"
          value = "traefik"
        }
        parameter {
          name  = "general.ingress_host"
          value = "media.stinkyboi.com"
        }
        parameter {
          name  = "general.storage.pvcStorageClass"
          value = "nfs-media"
        }
        parameter {
          name  = "plex.enabled"
          value = "false"
        }
        parameter {
          name  = "jackett.enabled"
          value = "false"
        }
        parameter {
          name  = "transmission.enabled"
          value = "false"
        }
        parameter {
          name  = "general.storage.size"
          value = "500Gi"
        }
        values = yamlencode({
          sabnzbd = {
            ingress = {
              tls = {
                enabled    = "true"
                secretName = "media-certificate-secret"
              }
            }
          }
          prowlarr = {
            ingress = {
              tls = {
                enabled    = "true"
                secretName = "media-certificate-secret"
              }
            }
          }
          radarr = {
            ingress = {
              tls = {
                enabled    = "true"
                secretName = "media-certificate-secret"
              }
            }
          }
          sonarr = {
            ingress = {
              tls = {
                enabled    = "true"
                secretName = "media-certificate-secret"
              }
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
