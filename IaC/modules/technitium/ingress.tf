resource "kubernetes_ingress_v1" "technitium" {
  wait_for_load_balancer = true
  metadata {
    name      = "technitium-ingress"
    namespace = kubernetes_namespace.technitium.metadata[0].name
  }
  spec {
    ingress_class_name = "traefik"
    rule {
      host = "manage.stinkyboi.com"
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
  }
}
