resource "aws_ssm_parameter" "openai_api_key" {
  #checkov:skip=CKV_AWS_337: Need to update with project key
  name        = "/homelab/open-webui/openai_api_key"
  description = "Secret for Open WebUI API key"
  type        = "SecureString"
  value       = "update_me"
  lifecycle {
    ignore_changes = [value]
  }
}
