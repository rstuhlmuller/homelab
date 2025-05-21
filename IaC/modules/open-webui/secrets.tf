resource "aws_ssm_parameter" "openai_api_key" {
  name        = "/homelab/open-webui/openai_api_key"
  description = "Secret for Open WebUI API key"
  type        = "SecureString"
  value       = "update_me"
  lifecycle {
    ignore_changes = [value]
  }
}
