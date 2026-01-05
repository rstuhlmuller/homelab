resource "kubernetes_namespace_v1" "minecraft" {
  metadata {
    name = "minecraft"
  }
}

resource "argocd_application" "minecraft" {
  metadata {
    name = "minecraft"
  }

  spec {
    project = "default"
    destination {
      server    = "https://kubernetes.default.svc"
      namespace = kubernetes_namespace_v1.minecraft.metadata[0].name
    }

    source {
      repo_url        = "https://itzg.github.io/minecraft-server-charts/"
      chart           = "minecraft"
      target_revision = "5.0.0"
      helm {
        parameter {
          name  = "minecraftServer.eula"
          value = "true"
        }
        parameter {
          name  = "persistence.dataDir.enabled"
          value = "true"
        }
        parameter {
          name  = "minecraftServer.serviceType"
          value = "LoadBalancer"
        }
        parameter {
          name  = "minecraftServer.levelSeed"
          value = "5794307532370510714"
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

resource "kubernetes_manifest" "minecraft_image_updater" {
  manifest = {
    apiVersion = "argocd-image-updater.argoproj.io/v1alpha1"
    kind       = "ImageUpdater"
    metadata = {
      name      = "minecraft-image-updater"
      namespace = kubernetes_namespace_v1.minecraft.metadata[0].name
    }
    spec = {
      namespace = "argocd"
      applicationRefs = [
        {
          namePattern = "minecraft"
          images = [
            {
              alias     = "minecraft"
              imageName = "itzg/minecraft-server:stable"
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
