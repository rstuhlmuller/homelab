resource "kubernetes_namespace" "descheduler" {
  metadata {
    name = "descheduler"
  }
}

resource "argocd_application" "descheduler" {
  metadata {
    name = "descheduler"
  }

  spec {
    project = "default"
    destination {
      server    = "https://kubernetes.default.svc"
      namespace = kubernetes_namespace.descheduler.metadata[0].name
    }

    source {
      repo_url        = "https://kubernetes-sigs.github.io/descheduler/"
      chart           = "descheduler"
      target_revision = "0.33.0"
    }
    sync_policy {
      automated {
        prune     = true
        self_heal = true
      }
    }
  }
}
