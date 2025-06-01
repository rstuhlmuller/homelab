resource "kubernetes_namespace" "postgresql" {
  metadata {
    name = "database"
  }
}

resource "argocd_application" "postgresql" {
  metadata {
    name = "postgresql"
  }

  spec {
    project = "default"
    destination {
      server    = "https://kubernetes.default.svc"
      namespace = kubernetes_namespace.postgresql.metadata[0].name
    }
    source {
      repo_url        = "https://charts.bitnami.com/bitnami"
      chart           = "postgresql"
      target_revision = "12.0.0"
      helm {
        parameter {
          name  = "global.defaultStorageClass"
          value = "nfs-database"
        }
        parameter {
          name  = "global.storageClass"
          value = "nfs-database"
        }
        parameter {
          name  = "auth.existingSecret"
          value = kubernetes_manifest.postgresql_secret.manifest.metadata.name
        }
        parameter {
          name  = "image.debug"
          value = "true"
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
