resource "kubernetes_ingress_v1" "traefik" {
  wait_for_load_balancer = true
  metadata {
    name      = "technitium"
    namespace = kubernetes_namespace.technitium.metadata[0].name
    annotations = {
      "traefik.ingress.kubernetes.io/router.entrypoints" = "websecure"
    }
  }
  spec {
    ingress_class_name = "traefik"
    rule {
      host = "dns.stinkyboi.com"
      http {
        path {
          path      = "/"
          path_type = "Prefix"
          backend {
            service {
              name = "technitium-technitium-dns-http"
              port {
                number = 5380
              }
            }
          }
        }
      }
    }
    tls {
      secret_name = kubernetes_manifest.technitium_certificate.manifest.spec.secretName
    }
  }
}

resource "kubernetes_manifest" "technitium_certificate" {
  manifest = {
    apiVersion = "cert-manager.io/v1"
    kind       = "Certificate"
    metadata = {
      name      = "technitium-ingressroute-certificate"
      namespace = kubernetes_namespace.technitium.metadata[0].name
    }
    spec = {
      secretName = "technitium-certificate-secret"
      issuerRef = {
        name = "cloudflare-clusterissuer"
        kind = "ClusterIssuer"
      }
      dnsNames = [
        "dns.stinkyboi.com"
      ]
    }
  }
}
