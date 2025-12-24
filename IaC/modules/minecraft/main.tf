resource "kubernetes_namespace_v1" "minecraft" {
  metadata {
    name = "minecraft"
  }
}

resource "argocd_application" "minecraft" {
  metadata {
    name = "minecraft"
    annotations = {
      "argocd-image-updater.argoproj.io/image-list"                = "minecraft=itzg/minecraft-server:latest"
      "argocd-image-updater.argoproj.io/minecraft.update-strategy" = "digest"
    }
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
