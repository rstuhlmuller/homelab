resource "kubernetes_namespace" "litellm" {
  metadata {
    name = "litellm"
  }
}

resource "argocd_application" "litellm" {
  metadata {
    name = "litellm"
    annotations = {
      "argocd-image-updater.argoproj.io/image-list"              = "litellm=ghcr.io/berriai/litellm:main-latest"
      "argocd-image-updater.argoproj.io/litellm.update-strategy" = "latest"
    }
  }

  spec {
    project = "default"
    destination {
      server    = "https://kubernetes.default.svc"
      namespace = kubernetes_namespace.litellm.metadata[0].name
    }

    source {
      repo_url        = "https://github.com/BerriAI/litellm.git"
      path            = "deploy/charts/litellm-helm"
      target_revision = "HEAD"
      helm {
        values = yamlencode({
          migrationJob = {
            enabled = false
          }
          image = {
            repository = "ghcr.io/berriai/litellm-non_root"
            pullPolicy = "Always"
            tag        = "main-v1.65.3-nightly"
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
            model_list = [
              {
                model_name = "Nova Pro"
                litellm_params = {
                  model           = "bedrock/amazon.nova-pro-v1:0"
                  aws_region_name = "us-east-1"
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
                  model           = "bedrock/converse/deepseek.r1-v1:0"
                  aws_region_name = "us-west-2"
                }
              },
              {
                model_name = "gpt-oss-120b"
                litellm_params = {
                  model           = "bedrock/openai.gpt-oss-120b-1:0"
                  aws_region_name = "us-west-2"
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
      namespace = kubernetes_namespace.litellm.metadata[0].name
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
