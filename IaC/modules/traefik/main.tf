resource "kubernetes_namespace_v1" "traefik" {
  metadata {
    name = "traefik"
  }
}

resource "helm_release" "traefik" {
  name       = "traefik"
  repository = "https://helm.traefik.io/traefik"
  chart      = "traefik"
  namespace  = kubernetes_namespace_v1.traefik.metadata[0].name
  set = [
    {
      name  = "image.pullPolicy"
      value = "Always"
    },
    {
      name  = "ingressRoute.dashboard.enabled"
      value = "true"
    },
    {
      name  = "ingressRoute.dashboard.entryPoints"
      value = "{websecure}"
    },
    {
      name  = "ingressRoute.dashboard.matchRule"
      value = "Host(`traefik.stinkyboi.com`) && PathPrefix(`/`)"
    },
    {
      name  = "ingressRoute.dashboard.tls.secretName"
      value = "traefik-certificate-secret"
    },
    {
      name  = "ports.web.redirections.entryPoint.to"
      value = "websecure"
    },
    {
      name  = "ports.web.redirections.entryPoint.scheme"
      value = "https"
    },
    {
      name  = "service.loadBalancerClass"
      value = "tailscale"
    }
  ]
}

resource "kubernetes_manifest" "traefik_certificate" {
  manifest = {
    apiVersion = "cert-manager.io/v1"
    kind       = "Certificate"
    metadata = {
      name      = "traefik"
      namespace = kubernetes_namespace_v1.traefik.metadata[0].name
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
