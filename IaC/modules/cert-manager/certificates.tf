resource "kubernetes_manifest" "open_webui_certificate" {
  manifest = {
    apiVersion = "cert-manager.io/v1"
    kind       = "Certificate"
    metadata = {
      name      = "open-webui-ingressroute-certificate"
      namespace = "open-webui"
    }
    spec = {
      secretName = "open-webui-certificate-secret"
      issuerRef = {
        name = "cloudflare-clusterissuer"
        kind = "ClusterIssuer"
      }
      dnsNames = [
        "chat.stinkyboi.com"
      ]
    }
  }
}

resource "kubernetes_manifest" "monitoring_certificate" {
  manifest = {
    apiVersion = "cert-manager.io/v1"
    kind       = "Certificate"
    metadata = {
      name      = "monitoring-ingressroute-certificate"
      namespace = "monitoring"
    }
    spec = {
      secretName = "monitoring-certificate-secret"
      issuerRef = {
        name = "cloudflare-clusterissuer"
        kind = "ClusterIssuer"
      }
      dnsNames = [
        "grafana.stinkyboi.com",
        "prometheus.stinkyboi.com"
      ]
    }
  }
}

resource "kubernetes_manifest" "traefik_certificate" {
  manifest = {
    apiVersion = "cert-manager.io/v1"
    kind       = "Certificate"
    metadata = {
      name      = "traefik"
      namespace = "traefik"
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

resource "kubernetes_manifest" "argocd_certificate" {
  manifest = {
    apiVersion = "cert-manager.io/v1"
    kind       = "Certificate"
    metadata = {
      name      = "argocd"
      namespace = "argocd"
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
