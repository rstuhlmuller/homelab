resource "aws_ssm_parameter" "open_webui_api_key" {
  name = "/homelab/open-webui/open-router-api-key"
  type = "SecureString"

  value = "open-router-api-key"

  lifecycle {
    ignore_changes = [value]
  }
  tags = local.tags
}

resource "kubernetes_secret" "open_webui_secret" {
  metadata {
    name      = "open-router-api-key"
    namespace = kubernetes_namespace.open_webui.metadata[0].name
  }

  data = {
    "open-router-api-key" = aws_ssm_parameter.open_webui_api_key.value
  }
}
