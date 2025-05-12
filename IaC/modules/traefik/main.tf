resource "kubernetes_namespace" "traefik" {
  metadata {
    name = "traefik"
  }
}

resource "helm_release" "traefik" {
  name       = "traefik"
  repository = "https://helm.traefik.io/traefik"
  chart      = "traefik"
  namespace  = kubernetes_namespace.traefik.metadata[0].name

  set {
    name  = "service.type"
    value = "LoadBalancer"
  }
  set {
    name  = "ingressRoute.dashboard.enabled"
    value = "true"
  }
  set {
    name  = "ingressRoute.dashboard.entryPoints"
    value = "{web}"
  }
}
