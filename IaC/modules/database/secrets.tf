locals {
  secrets = [
    "postgres-password",
    "password",
    "replication-password"
  ]
}
resource "aws_ssm_parameter" "postgresql_secret" {
  #checkov:skip=CKV_AWS_337: Need to update with project key
  for_each = toset(local.secrets)
  name     = "/homelab/${kubernetes_namespace_v1.postgresql.metadata[0].name}/${each.key}"
  type     = "SecureString"
  value    = "update_me"
  lifecycle {
    ignore_changes = [value]
  }
}

resource "kubernetes_manifest" "postgresql_secret" {
  manifest = {
    apiVersion = "external-secrets.io/v1"
    kind       = "ExternalSecret"
    metadata = {
      name      = "postgresql-secret"
      namespace = kubernetes_namespace_v1.postgresql.metadata[0].name
    }
    spec = {
      secretStoreRef = {
        name = "parameterstore"
        kind = "ClusterSecretStore"
      }
      refreshInterval = "10m"
      data = [for k, v in aws_ssm_parameter.postgresql_secret : {
        secretKey = k
        remoteRef = {
          key = v.name
        }
      }]
    }
  }
}
