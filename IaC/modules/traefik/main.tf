resource "kubernetes_namespace" "traefik" {
  metadata {
    name = "traefik"
  }
}

resource "helm_release" "traefik" {
  name             = "traefik"
  repository       = "https://traefik.github.io/charts"
  chart            = "traefik"
  namespace        = kubernetes_namespace.traefik.metadata[0].name
  create_namespace = true

  set {
    name  = "ingressRoute.dashboard.enabled"
    value = "true"
  }

  set {
    name  = "ingressRoute.dashboard.entryPoints"
    value = "{web}"
  }
}
