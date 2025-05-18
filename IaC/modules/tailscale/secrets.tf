resource "aws_ssm_parameter" "oauth_secret" {
  for_each = toset(["oauth_client_id", "oauth_client_secret", "tailscale_auth_key"])
  name     = "/homelab/tailscale/${each.key}"
  type     = "SecureString"
  value    = "update_me"
  lifecycle {
    ignore_changes = [value]
  }
}

resource "kubernetes_secret" "tailscale_auth_key" {
  metadata {
    name      = "tailscale-auth"
    namespace = kubernetes_namespace.tailscale.metadata[0].name
  }
  type = "Opaque"
  data = {
    api_key = aws_ssm_parameter.oauth_secret["tailscale_auth_key"].value
  }
}
