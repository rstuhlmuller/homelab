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
        value_files = ["values.yaml"]
        values = yamlencode({
          ollama = {
            enabled = false
          }
          pipelines = {
            enabled = false
          }
          enableOpenaiApi  = true
          openaiBaseApiUrl = "https://openrouter.ai/api/v1"
          extraEnvVars = [
            {
              name = "OPENAI_API_KEY"
              valueFrom = {
                secretKeyRef = {
                  name = "${kubernetes_secret.open_webui_secret.metadata[0].name}"
                  key  = "open-router-api-key"
                }
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
