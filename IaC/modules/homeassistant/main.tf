resource "kubernetes_namespace" "homeassistant" {
  metadata {
    name = "homeassistant"
  }
}

resource "argocd_application" "homeassistant" {
  metadata {
    name = "homeassistant"
  }

  spec {
    project = "default"
    destination {
      server    = "https://kubernetes.default.svc"
      namespace = kubernetes_namespace.homeassistant.metadata[0].name
    }

    source {
      repo_url        = "http://pajikos.github.io/home-assistant-helm-chart/"
      chart           = "home-assistant"
      target_revision = "0.3.4"
      helm {
        values = yamlencode({
          ingress = {
            enabled   = true
            className = "traefik"
            hosts = [{
              host = "home.stinkyboi.com"
              paths = [{
                path     = "/"
                pathType = "Prefix"
              }]
            }]
            tls = [{
              secretName = kubernetes_manifest.certificate.manifest.spec.secretName
              hosts      = ["home.stinkyboi.com"]
            }]
          }
          configuration = {
            enabled = true
            trusted_proxies = [
              "10.0.0.0/8"
            ]
          }
          persistence = {
            enabled = true
          }
        })
      }
    }
    sync_policy {
      automated {
        prune     = true
        self_heal = true
      }
    }
  }
}

resource "kubernetes_manifest" "certificate" {
  manifest = {
    apiVersion = "cert-manager.io/v1"
    kind       = "Certificate"
    metadata = {
      name      = "homeassistant-ingressroute-certificate"
      namespace = "homeassistant"
    }
    spec = {
      secretName = "homeassistant-certificate-secret"
      issuerRef = {
        name = "cloudflare-clusterissuer"
        kind = "ClusterIssuer"
      }
      dnsNames = [
        "home.stinkyboi.com"
      ]
    }
  }
}
