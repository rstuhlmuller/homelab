resource "kubernetes_ingress_v1" "traefik" {
  wait_for_load_balancer = true
  metadata {
    name      = "open-webui-ingress"
    namespace = kubernetes_namespace_v1.open_webui.metadata[0].name
  }
  spec {
    ingress_class_name = "cloudflare-tunnel"
    rule {
      host = "chat.stinkyboi.com"
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

resource "kubernetes_ingress_v1" "mcpo" {
  wait_for_load_balancer = true
  metadata {
    name      = "open-webui-mcpo-ingress"
    namespace = kubernetes_namespace_v1.open_webui.metadata[0].name
  }
  spec {
    ingress_class_name = "cloudflare-tunnel"
    rule {
      host = "mcpo.stinkyboi.com"
      http {
        path {
          path      = "/"
          path_type = "Prefix"
          backend {
            service {
              name = "open-webui-mcpo"
              port {
                number = 8000
              }
            }
          }
        }
      }
    }
  }
}
