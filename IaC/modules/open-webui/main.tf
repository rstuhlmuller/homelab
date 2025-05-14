resource "kubernetes_namespace" "open_webui" {
  metadata {
    name = "open-webui"
  }
}

resource "argocd_application" "open_webui" {
  metadata {
    name = "open-webui"
  }

  spec {
    project = "default"
    destination {
      server    = "https://kubernetes.default.svc"
      namespace = kubernetes_namespace.open_webui.metadata[0].name
    }

    source {
      repo_url        = "https://helm.openwebui.com/"
      chart           = "open-webui"
      target_revision = "6.13.0"
      helm {
        parameter {
          name  = "ollama.enabled"
          value = "false"
        }
        parameter {
          name  = "pipelines.enabled"
          value = "false"
        }
        parameter {
          name  = "image.tag"
          value = "0.6.9"
        }
        parameter {
          name  = "replicaCount"
          value = "2"
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
