resource "kubernetes_namespace" "open_webui" {
  metadata {
    name = "open-webui"
  }
}

resource "argocd_application" "open_webui" {
  metadata {
    name = "open-webui"
    annotations = {
      "argocd-image-updater.argoproj.io/image-list"                 = "open-webui=ghcr.io/open-webui/open-webui:0.x"
      "argocd-image-updater.argoproj.io/open-webui.update-strategy" = "semver"
    }
  }

  spec {
    project = "default"
    destination {
      server    = "https://kubernetes.default.svc"
      namespace = kubernetes_namespace.open_webui.metadata[0].name
    }

    source {
      repo_url        = "https://github.com/rstuhlmuller/openwebui-helm-charts.git"
      path            = "charts/open-webui"
      target_revision = "HEAD"
      helm {
        parameter {
          name  = "ollama.enabled"
          value = "false"
        }
        parameter {
          name  = "mcpo.enabled"
          value = "true"
        }
        parameter {
          name  = "pipelines.enabled"
          value = "false"
        }
        parameter {
          name  = "openaiBaseApiUrl"
          value = "https://litellm.stinkyboi.com/"
        }
        parameter {
          name  = "config"
          value = "{}"
        }
        parameter {
          name  = "config"
          value = "{}"
        }
        values = yamlencode({
          extraEnvVars = [{
            name = "OPENAI_API_KEY"
            valueFrom = {
              secretKeyRef = {
                name = kubernetes_manifest.open_webui_secret.manifest.metadata.name
                key  = "openai_api_key"
              }
            }
          }]
          config = {
            mcpServers = {
              time = {
                command = "uvx"
                args    = ["mcp-server-time", "--local-timezone=America/Los_Angeles"]
              }
            }
          }
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
