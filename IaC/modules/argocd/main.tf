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
    global = {
      domain                   = "argocd.stinkyboi.com"
      addPrometheusAnnotations = "true"
    }
    image = {
      pullPolicy = "Always"
    }
    server = {
      metrics = {
        enabled = true
      }
      certificate = {
        enabled    = true
        secretName = "argocd-server-tls"
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
    configs = {
      params = {
        "server.insecure" = "true"
      }
      secret = {
        createSecret = true
      }
      rbac = {
        create       = true
        "policy.csv" = <<EOF
p, app_user, *, *, *, allow
EOF
      }
      cm = {
        "accounts.app_user"         = "apiKey"
        "accounts.app_user.enabled" = true
      }
    }
  })]
}

resource "kubernetes_manifest" "argocd_certificate" {
  manifest = {
    apiVersion = "cert-manager.io/v1"
    kind       = "Certificate"
    metadata = {
      name      = "argocd"
      namespace = kubernetes_namespace.argocd.metadata[0].name
    }
    spec = {
      secretName = "argocd-server-tls"
      issuerRef = {
        name = "cloudflare-clusterissuer"
        kind = "ClusterIssuer"
      }
      dnsNames = [
        "argocd.stinkyboi.com"
      ]
    }
  }
}
