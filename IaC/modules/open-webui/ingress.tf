resource "kubernetes_ingress_v1" "traefik" {
  wait_for_load_balancer = true
  metadata {
    name      = "open-webui-ingress"
    namespace = kubernetes_namespace.open_webui.metadata[0].name
  }
  spec {
    ingress_class_name = "tailscale"
    default_backend {
      service {
        name = "open-webui"
        port {
          number = 80
        }
      }
    }
    tls {
      hosts       = ["chat"]
      secret_name = "open-webui-certificate-secret"
    }
  }
}

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
