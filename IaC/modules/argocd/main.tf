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

  values = [yamlencode({
    server = {
      global = {
        domain = "argocd.stinkyboi.com"
      }
      ingress = {
        enabled          = true
        ingressClassName = "traefik"
        hostname         = "argocd.stinkyboi.com"
        tls              = true
      }
    }
  })]
}
