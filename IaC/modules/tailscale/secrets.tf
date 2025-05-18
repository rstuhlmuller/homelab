resource "aws_ssm_parameter" "oauth_secret" {
  for_each = toset(["oauth_client_id", "oauth_client_secret"])
  name     = "/homelab/tailscale/${each.key}"
  type     = "SecureString"
  value    = "update_me"
  lifecycle {
    ignore_changes = [value]
  }
}
