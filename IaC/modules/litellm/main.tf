resource "kubernetes_namespace" "open_webui" {
  metadata {
    name = "litellm"
  }
}
