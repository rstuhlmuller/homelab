resource "kubernetes_namespace" "open_webui" {
  metadata {
    name = "open-webui"
  }
}

resource "aws_ssm_parameter" "open_webui_api_key" {
  name = "/homelab/open-webui/open-router-api-key"
  type = "SecureString"

  value = "open-router-api-key"

  lifecycle {
    ignore_changes = [value]
  }
}

resource "kubernetes_secret" "open_webui_secret" {
  metadata {
    name      = "open-router-api-key"
    namespace = kubernetes_namespace.open_webui.metadata[0].name
  }

  data = {
    "open-router-api-key" = aws_ssm_parameter.open_webui_api_key.value
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
          service = {
            type = "LoadBalancer"
          }
          extraEnvVars = [
            {
              name  = "ENABLE_OPENAI_API"
              value = "true"
            },
            {
              name  = "OPENAI_API_BASE_URL"
              value = "https://openrouter.ai/api/v1"
            },
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
