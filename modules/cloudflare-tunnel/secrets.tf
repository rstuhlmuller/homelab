resource "aws_ssm_parameter" "secret" {
  #checkov:skip=CKV_AWS_337: Need to update with project key
  for_each = toset(["api_token", "account_id", "tunnel_name"])
  name     = "/homelab/cloudflare-tunnel/${each.key}"
  type     = "SecureString"
  value    = "update_me"
  lifecycle {
    ignore_changes = [value]
  }
}

resource "kubernetes_manifest" "secret" {
  manifest = {
    apiVersion = "external-secrets.io/v1"
    kind       = "ExternalSecret"
    metadata = {
      name      = "cloudflare-secret"
      namespace = kubernetes_namespace.cloudflare-tunnel.metadata[0].name
    }
    spec = {
      secretStoreRef = {
        name = "parameterstore"
        kind = "ClusterSecretStore"
      }
      refreshPolicy = "OnChange"
      data = [for key, value in aws_ssm_parameter.secret : {
        secretKey = key
        remoteRef = {
          key = value.name
        }
      }]
    }
  }
}
