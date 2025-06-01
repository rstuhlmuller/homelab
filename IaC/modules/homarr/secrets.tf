resource "aws_ssm_parameter" "db_secret" {
  for_each = toset(["db-encryption-key", "db-url", "mysql-root-password", "mysql-password"])
  #checkov:skip=CKV_AWS_337: Need to update with project key
  name        = "/homelab/${kubernetes_namespace.homarr.metadata[0].name}/${each.key}"
  description = "Secret for db-secret key used by homarr"
  type        = "SecureString"
  value       = "update_me"
  lifecycle {
    ignore_changes = [value]
  }
}

resource "kubernetes_manifest" "db_secret" {
  manifest = {
    apiVersion = "external-secrets.io/v1"
    kind       = "ExternalSecret"
    metadata = {
      name      = "db-secret"
      namespace = kubernetes_namespace.homarr.metadata[0].name
    }
    spec = {
      secretStoreRef = {
        name = "parameterstore"
        kind = "ClusterSecretStore"
      }
      refreshPolicy   = "Periodic"
      refreshInterval = "30s"
      data = [for key, value in aws_ssm_parameter.db_secret : {
        secretKey = key
        remoteRef = {
          key = value.name
        }
      }]
    }
  }
}
