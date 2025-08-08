resource "aws_ssm_parameter" "litellm" {
  for_each = toset(["username", "password"])
  #checkov:skip=CKV_AWS_337: Need to update with project key
  name        = "/homelab/${kubernetes_namespace.litellm.metadata[0].name}/database/${each.key}"
  description = "Secret for Open WebUI"
  type        = "SecureString"
  value       = "update_me"
  lifecycle {
    ignore_changes = [value]
  }
}

resource "kubernetes_manifest" "litellm_secret" {
  manifest = {
    apiVersion = "external-secrets.io/v1"
    kind       = "ExternalSecret"
    metadata = {
      name      = "postgres"
      namespace = kubernetes_namespace.litellm.metadata[0].name
    }
    spec = {
      secretStoreRef = {
        name = "parameterstore"
        kind = "ClusterSecretStore"
      }
      refreshPolicy = "OnChange"
      data = [for key, value in aws_ssm_parameter.litellm : {
        secretKey = key
        remoteRef = {
          key = value.name
        }
      }]
    }
  }
}

resource "aws_ssm_parameter" "litellm_env" {
  for_each = toset(["AWS_ACCESS_KEY_ID", "AWS_SECRET_ACCESS_KEY", "AWS_REGION_NAME"])
  #checkov:skip=CKV_AWS_337: Need to update with project key
  name        = "/homelab/${kubernetes_namespace.litellm.metadata[0].name}/env/${each.key}"
  description = "Secret for Open WebUI"
  type        = "SecureString"
  value       = "update_me"
  lifecycle {
    ignore_changes = [value]
  }
}

resource "kubernetes_manifest" "litellm_env_secret" {
  manifest = {
    apiVersion = "external-secrets.io/v1"
    kind       = "ExternalSecret"
    metadata = {
      name      = "litellm-env"
      namespace = kubernetes_namespace.litellm.metadata[0].name
    }
    spec = {
      secretStoreRef = {
        name = "parameterstore"
        kind = "ClusterSecretStore"
      }
      refreshPolicy = "OnChange"
      data = [for key, value in aws_ssm_parameter.litellm_env : {
        secretKey = key
        remoteRef = {
          key = value.name
        }
      }]
    }
  }
}
