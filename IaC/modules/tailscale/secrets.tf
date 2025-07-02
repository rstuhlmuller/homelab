resource "aws_ssm_parameter" "oauth_secret" {
  #checkov:skip=CKV_AWS_337: Need to update with project key
  for_each = toset(["client_id", "client_secret"])
  name     = "/homelab/tailscale/${each.key}"
  type     = "SecureString"
  value    = "update_me"
  lifecycle {
    ignore_changes = [value]
  }
}

resource "kubernetes_manifest" "oauth_secret" {
  manifest = {
    apiVersion = "external-secrets.io/v1"
    kind       = "ExternalSecret"
    metadata = {
      name      = "operator-oauth"
      namespace = kubernetes_namespace.tailscale.metadata[0].name
    }
    spec = {
      secretStoreRef = {
        name = "parameterstore"
        kind = "ClusterSecretStore"
      }
      refreshPolicy   = "Periodic"
      refreshInterval = "30s"
      data = [for key, value in aws_ssm_parameter.oauth_secret : {
        secretKey = key
        remoteRef = {
          key = value.name
        }
      }]
    }
  }
}
