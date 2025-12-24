resource "kubernetes_namespace_v1" "litellm" {
  metadata {
    name = "litellm"
  }
}

resource "argocd_application" "litellm" {
  metadata {
    name = "litellm"
    annotations = {
      "argocd-image-updater.argoproj.io/image-list"              = "litellm=ghcr.io/berriai/litellm-database:main-stable"
      "argocd-image-updater.argoproj.io/litellm.update-strategy" = "digest"
    }
  }

  spec {
    project = "default"
    destination {
      server    = "https://kubernetes.default.svc"
      namespace = kubernetes_namespace_v1.litellm.metadata[0].name
    }

    source {
      repo_url        = "https://github.com/BerriAI/litellm.git"
      path            = "deploy/charts/litellm-helm"
      target_revision = "HEAD"
      helm {
        values = yamlencode({
          image = {
            tag = "main-stable"
          }
          migrationJob = {
            enabled = false
          }
          db = {
            deployStandalone = false
            useExisting      = true
            endpoint         = "postgresql.database.svc.cluster.local:5432"
          }
          ingress = {
            enabled   = true
            className = "traefik"
            hosts = [
              {
                host = "litellm.stinkyboi.com"
                paths = [
                  {
                    path     = "/"
                    pathType = "ImplementationSpecific"
                  }
                ]
              }
            ]
            tls = [
              {
                secretName = "litellm-tls"
                hosts      = ["litellm"]
              }
            ]
          }
          environmentSecrets = ["litellm-env"]
          proxy_config = {
            general_settings = {
              store_model_in_db           = true
              store_prompts_in_spend_logs = true
            }
            model_list = [
              {
                model_name = "Nova Pro"
                litellm_params = {
                  model           = "bedrock/us.amazon.nova-pro-v1:0"
                  aws_region_name = "us-west-2"
                }
              },
              {
                model_name = "Claude Sonnet 4"
                litellm_params = {
                  model           = "bedrock/us.anthropic.claude-sonnet-4-20250514-v1:0"
                  aws_region_name = "us-west-2"
                }
              },
              {
                model_name = "DeepSeek-R1"
                litellm_params = {
                  model           = "bedrock/us.deepseek.r1-v1:0"
                  aws_region_name = "us-west-2"
                }
              },
              {
                model_name = "gpt-5-2025-08-07"
                litellm_params = {
                  model   = "openai/gpt-5-2025-08-07"
                  api_key = "os.environ/OPENAI_API_KEY"
                }
              },
              {
                model_name = "gpt-3.5-turbo"
                litellm_params = {
                  model   = "openai/gpt-3.5-turbo"
                  api_key = "os.environ/OPENAI_API_KEY"
                }
              },
              {
                model_name = "gpt-image-1"
                litellm_params = {
                  model   = "openai/gpt-image-1"
                  api_key = "os.environ/OPENAI_API_KEY"
                }
              }
            ]
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

resource "kubernetes_manifest" "litellm_tls" {
  manifest = {
    apiVersion = "cert-manager.io/v1"
    kind       = "Certificate"
    metadata = {
      name      = "litellm-tls"
      namespace = kubernetes_namespace_v1.litellm.metadata[0].name
    }
    spec = {
      secretName = "litellm-tls"
      issuerRef = {
        name = "cloudflare-clusterissuer"
        kind = "ClusterIssuer"
      }
      dnsNames = [
        "litellm.stinkyboi.com"
      ]
    }
  }
}
