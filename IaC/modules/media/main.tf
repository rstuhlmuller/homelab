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
          value = "nfs-client"
        }
        parameter {
          name  = "plex.enabled"
          value = "false"
        }
        parameter {
          name  = "sabnzbd.enabled"
          value = "false"
        }
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
