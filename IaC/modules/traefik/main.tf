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
    name  = "image.pullPolicy"
    value = "Always"
  }
  set {
    name  = "ingressRoute.dashboard.enabled"
    value = "true"
  }
  set {
    name  = "ingressRoute.dashboard.entryPoints"
    value = "{websecure}"
  }
  set {
    name  = "ingressRoute.dashboard.matchRule"
    value = "Host(`traefik.stinkyboi.com`) && PathPrefix(`/`)"
  }
  set {
    name  = "ingressRoute.dashboard.tls.secretName"
    value = "traefik-certificate-secret"
  }
  set {
    name  = "ports.web.redirections.entryPoint.to"
    value = "websecure"
  }
  set {
    name  = "ports.web.redirections.entryPoint.scheme"
    value = "https"
  }
}

resource "kubernetes_manifest" "traefik_certificate" {
  manifest = {
    apiVersion = "cert-manager.io/v1"
    kind       = "Certificate"
    metadata = {
      name      = "traefik"
      namespace = kubernetes_namespace.traefik.metadata[0].name
    }
    spec = {
      secretName = "traefik-certificate-secret"
      issuerRef = {
        name = "cloudflare-clusterissuer"
        kind = "ClusterIssuer"
      }
      dnsNames = [
        "traefik.stinkyboi.com"
      ]
    }
  }
}
