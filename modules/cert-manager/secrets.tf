resource "aws_ssm_parameter" "cloudflare_api_key_secret" {
  #checkov:skip=CKV_AWS_337: Need to update with project key
  name        = "/homelab/${kubernetes_namespace.cert_manager.metadata[0].name}/api_key"
  description = "Secret for Cloudflare API key used by cert-manager"
  type        = "SecureString"
  value       = "update_me"
  lifecycle {
    ignore_changes = [value]
  }
}

resource "kubernetes_manifest" "cloudflare_api_key_secret" {
  manifest = {
    apiVersion = "external-secrets.io/v1"
    kind       = "ExternalSecret"
    metadata = {
      name      = "cloudflare-api-key-secret"
      namespace = kubernetes_namespace.cert_manager.metadata[0].name
    }
    spec = {
      secretStoreRef = {
        name = "parameterstore"
        kind = "ClusterSecretStore"
      }
      refreshPolicy = "OnChange"
      data = [{
        secretKey = "api_key"
        remoteRef = {
          key = aws_ssm_parameter.cloudflare_api_key_secret.name
        }
      }]
    }
  }
}
