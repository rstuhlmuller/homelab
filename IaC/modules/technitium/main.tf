resource "kubernetes_namespace" "technitium" {
  metadata {
    name = "technitium"
    labels = {
      "pod-security.kubernetes.io/enforce" = "privileged"
    }
  }
}

resource "kubernetes_persistent_volume_claim" "technitium_config" {
  metadata {
    name      = "technitium-config-pvc"
    namespace = kubernetes_namespace.technitium.metadata[0].name
  }

  spec {
    access_modes = ["ReadWriteMany"]
    resources {
      requests = {
        storage = "1Gi"
      }
    }
    storage_class_name = "nfs-client"
  }
}

resource "argocd_application" "technitium" {
  metadata {
    name = "technitium"
    annotations = {
      "argocd-image-updater.argoproj.io/image-list"                = "technitium=technitium/dns-server:13.x"
      "argocd-image-updater.argoproj.io/tailscale.update-strategy" = "semver"
    }
  }

  spec {
    project = "default"
    destination {
      server    = "https://kubernetes.default.svc"
      namespace = kubernetes_namespace.technitium.metadata[0].name
    }

    source {
      repo_url = "https://github.com/aaronsteed/technitium-dns-kube-controller"
      path     = "chart/technitium-dns"

      helm {
        parameter {
          name  = "controller.namespace"
          value = kubernetes_namespace.technitium.metadata[0].name
        }
        parameter {
          name  = "image.tag"
          value = "13.6.0"
        }
        values = yamlencode({
          imagePullSecrets = []
          volumes = [
            {
              name = "dns-config-hostpath"
              persistentVolumeClaim = {
                claimName = kubernetes_persistent_volume_claim.technitium_config.metadata[0].name
              }
            }
          ]
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
