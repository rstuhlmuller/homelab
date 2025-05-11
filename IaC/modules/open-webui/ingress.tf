resource "kubernetes_ingress_v1" "traefik" {
  wait_for_load_balancer = true
  metadata {
    name      = "open-webui-ingress"
    namespace = kubernetes_namespace.open_webui.metadata[0].name
  }
  spec {
    ingress_class_name = "traefik"
    rule {
      host = "open-webui.stinkyboi.com"
      http {
        path {
          path      = "/"
          path_type = "Prefix"
          backend {
            service {
              name = "open-webui"
              port {
                number = 80
              }
            }
          }
        }
      }
    }
  }
}
