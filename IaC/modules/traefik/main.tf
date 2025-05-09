resource "kubernetes_namespace" "traefik" {
  metadata {
    name = "traefik"
  }
}
