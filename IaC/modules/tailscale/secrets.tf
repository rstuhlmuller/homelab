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
