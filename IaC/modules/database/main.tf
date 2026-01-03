resource "kubernetes_namespace_v1" "postgresql" {
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
      namespace = kubernetes_namespace_v1.postgresql.metadata[0].name
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
          name  = "image.pullPolicy"
          value = "Always"
        }
        parameter {
          name  = "image.repository"
          value = "bitnamisecure/postgresql"
        }
        parameter {
          name  = "image.tag"
          value = "latest"
        }
        parameter {
          name  = "global.postgresql.auth.database"
          value = "metrics"
        }
        parameter {
          name  = "metrics.enabled"
          value = "true"
        }
        parameter {
          name  = "metrics.image.repository"
          value = "bitnamisecure/postgres-exporter"
        }
        parameter {
          name  = "metrics.image.tag"
          value = "latest"
        }
        parameter {
          name  = "metrics.serviceMonitor.enabled"
          value = "true"
        }
        parameter {
          name  = "volumePermissions.enabled"
          value = "true"
        }
        parameter {
          name  = "securityContext.fsGroup"
          value = "1001"
        }
        parameter {
          name  = "securityContext.runAsUser"
          value = "1001"
        }
        parameter {
          name  = "containerSecurityContext.runAsNonRoot"
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

# resource "kubernetes_manifest" "postgresql_image_updater" {
#   manifest = {
#     apiVersion = "argocd-image-updater.argoproj.io/v1alpha1"
#     kind       = "ImageUpdater"
#     metadata = {
#       name      = "postgresql-image-updater"
#       namespace = kubernetes_namespace_v1.postgresql.metadata[0].name
#     }
#   spec = {
#     namespace = "argocd"
#     applicationRefs = [
#       {
#         namePattern = "postgresql"
#         images = [
#           {
#             alias     = "postgresql"
#             imageName = "bitnamisecure/postgresql"
#             commonUpdateSettings = {
#               updateStrategy = "newest-build"
#             }
#           },
#           {
#             alias     = "postgres-exporter"
#             imageName = "bitnamisecure/postgres-exporter"
#             commonUpdateSettings = {
#               updateStrategy = "newest-build"
#             }
#           }
#         ]
#       }
#     ]
#     }
#   }
# }
