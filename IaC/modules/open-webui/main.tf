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
          value = "latest"
        }
        parameter {
          name  = "image.pullPolicy"
          value = "Always"
        }
        parameter {
          name  = "openaiBaseApiUrl"
          value = "https://openrouter.ai/api/v1"
        }
        values = yamlencode({
          extraEnvVars = [{
            name = "OPENAI_API_KEY"
            valuFrom = {
              secretKeyRef = {
                name = kubernetes_manifest.open_webui_secret.manifest.metadata.name
                key  = "openai_api_key"
              }
            }
          }]
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
