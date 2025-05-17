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
    name  = "ingressRoute.dashboard.enabled"
    value = "true"
  }
  set {
    name  = "ingressRoute.dashboard.entryPoints"
    value = "{web}"
  }
  # set {
  #   name  = "ingressRoute.dashboard.matchRule"
  #   value = "Host(`traefik.stinkyboi.com`) && (PathPrefix(`/dashboard`) || PathPrefix(`/api`))"
  # }
  # set {
  #   name  = "ingressRoute.dashboard.tls.secret_name"
  #   value = "traefik-certificate-secret"
  # }
}
