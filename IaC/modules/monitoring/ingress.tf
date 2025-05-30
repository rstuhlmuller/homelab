resource "kubernetes_ingress_v1" "traefik" {
  wait_for_load_balancer = true
  metadata {
    name      = "monitoring-ingress"
    namespace = kubernetes_namespace.monitoring.metadata[0].name
    annotations = {
      "traefik.ingress.kubernetes.io/router.entrypoints" = "websecure"
    }
  }
  spec {
    ingress_class_name = "traefik"
    rule {
      host = "prometheus.stinkyboi.com"
      http {
        path {
          path      = "/"
          path_type = "Prefix"
          backend {
            service {
              name = "prometheus-server"
              port {
                number = 80
              }
            }
          }
        }
      }
    }
    rule {
      host = "grafana.stinkyboi.com"
      http {
        path {
          path      = "/"
          path_type = "Prefix"
          backend {
            service {
              name = "grafana"
              port {
                number = 80
              }
            }
          }
        }
      }
    }
    tls {
      secret_name = "monitoring-certificate-secret"
    }
  }
}
