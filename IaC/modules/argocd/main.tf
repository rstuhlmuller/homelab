resource "kubernetes_namespace" "argocd" {
  metadata {
    name = "argocd"
    labels = {
      "name" = "argocd"
    }
  }
}

resource "helm_release" "release" {
  name       = "argocd"
  chart      = "argo-cd"
  repository = "https://argoproj.github.io/argo-helm"
  version    = "7.7.14"
  timeout    = "1500"
  namespace  = kubernetes_namespace.argocd.metadata[0].name

  set {
    name  = "global.domain"
    value = "argocd.stinkyboi.com"
  }

  values = [yamlencode({
    server = {
      certificate = {
        enabled    = true
        secretName = "argocd-server-tls"
        domain     = "argocd.stinkyboi.com"
        issuer = {
          group = "cert-manager.io"
          kind  = "ClusterIssuer"
          name  = "cloudflare-clusterissuer"
        }
      }
      ingress = {
        enabled          = true
        ingressClassName = "traefik"
        tls              = true
        annotations = {
          "traefik.ingress.kubernetes.io/router.entrypoints" = "websecure"
        }
      }
    }
  })]
}
