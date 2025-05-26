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
    }
    sync_policy {
      automated {
        prune     = true
        self_heal = true
      }
    }
  }
}
