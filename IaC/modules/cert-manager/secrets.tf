resource "aws_ssm_parameter" "cloudflare_api_key" {
  #checkov:skip=CKV_AWS_337: Need to update with project key
  name  = "/homelab/cloudflare/api_key"
  type  = "SecureString"
  value = "update_me"

  lifecycle {
    ignore_changes = [value]
  }
}

resource "kubernetes_secret" "cloudflare_api_key" {
  #checkov:skip=CKV_AWS_337: Need to update with project key
  metadata {
    name      = "cloudflare-api-key-secret"
    namespace = kubernetes_namespace.cert_manager.metadata[0].name
  }
  type = "Opaque"
  data = {
    api_key = aws_ssm_parameter.cloudflare_api_key.value
  }
}
