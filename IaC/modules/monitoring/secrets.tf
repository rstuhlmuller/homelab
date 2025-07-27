resource "aws_ssm_parameter" "umami" {
  for_each = toset(["umami_database_url"])
  #checkov:skip=CKV_AWS_337: Need to update with project key
  name             = "/homelab/${kubernetes_namespace.monitoring.metadata[0].name}/${each.key}"
  description      = "Secret for Umami"
  type             = "SecureString"
  value_wo         = "update_me"
  value_wo_version = 0
}

resource "kubernetes_manifest" "umami_secret" {
  manifest = {
    apiVersion = "external-secrets.io/v1"
    kind       = "ExternalSecret"
    metadata = {
      name      = "umami-secret"
      namespace = kubernetes_namespace.monitoring.metadata[0].name
    }
    spec = {
      secretStoreRef = {
        name = "parameterstore"
        kind = "ClusterSecretStore"
      }
      refreshPolicy = "OnChange"
      data = [for key, value in aws_ssm_parameter.umami : {
        secretKey = key
        remoteRef = {
          key = value.name
        }
      }]
    }
  }
}
