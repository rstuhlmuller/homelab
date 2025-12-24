resource "aws_ssm_parameter" "open_webui" {
  for_each = toset(["openai_api_key"])
  #checkov:skip=CKV_AWS_337: Need to update with project key
  name        = "/homelab/${kubernetes_namespace_v1.open_webui.metadata[0].name}/${each.key}"
  description = "Secret for Open WebUI"
  type        = "SecureString"
  value       = "update_me"
  lifecycle {
    ignore_changes = [value]
  }
}

resource "kubernetes_manifest" "open_webui_secret" {
  manifest = {
    apiVersion = "external-secrets.io/v1"
    kind       = "ExternalSecret"
    metadata = {
      name      = "open-webui-secret"
      namespace = kubernetes_namespace_v1.open_webui.metadata[0].name
    }
    spec = {
      secretStoreRef = {
        name = "parameterstore"
        kind = "ClusterSecretStore"
      }
      refreshPolicy = "OnChange"
      data = [for key, value in aws_ssm_parameter.open_webui : {
        secretKey = key
        remoteRef = {
          key = value.name
        }
      }]
    }
  }
}
