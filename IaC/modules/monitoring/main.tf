resource "kubernetes_namespace_v1" "monitoring" {
  metadata {
    name = "monitoring"
    labels = {
      "pod-security.kubernetes.io/enforce" = "privileged",
      "pod-security.kubernetes.io/audit"   = "privileged",
      "pod-security.kubernetes.io/warn"    = "privileged"
    }
  }
}

resource "argocd_application" "prometheus" {
  metadata {
    name = "prometheus"
  }

  spec {
    project = "default"
    destination {
      server    = "https://kubernetes.default.svc"
      namespace = kubernetes_namespace_v1.monitoring.metadata[0].name
    }

    source {
      repo_url        = "https://prometheus-community.github.io/helm-charts"
      chart           = "kube-prometheus-stack"
      target_revision = "80.10.0"
      helm {
        parameter {
          name  = "alertmanager.enabled"
          value = "false"
        }
        parameter {
          name  = "grafana.enabled"
          value = "false"
        }
      }
    }

    sync_policy {
      automated {
        prune     = true
        self_heal = true
      }
      sync_options = ["ServerSideApply=true"]
    }
  }
}

resource "argocd_application" "grafana" {
  metadata {
    name = "grafana"
  }

  spec {
    project = "default"
    destination {
      server    = "https://kubernetes.default.svc"
      namespace = kubernetes_namespace_v1.monitoring.metadata[0].name
    }

    source {
      repo_url        = "https://grafana.github.io/helm-charts"
      chart           = "grafana"
      target_revision = "10.4.2"
      helm {
        value_files = ["values.yaml"]
        values = yamlencode({
          ingress = {
            enabled = true
            hosts = [
              "grafana.stinkyboi.com"
            ]
            tls = [{
              secretName = kubernetes_manifest.monitoring_certificate.manifest["spec"]["secretName"]
              hosts      = ["grafana.stinkyboi.com"]
            }]
          }
          persistence = {
            enabled = true
          }
          initChownData = {
            enabled = false
          }
          env = {
            GF_SERVER_ROOT_URL = "https://grafana.stinkyboi.com/"
            GF_DATABASE_WAL    = true
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

resource "argocd_application" "umami" {
  metadata {
    name = "umami"
  }

  spec {
    project = "default"
    destination {
      server    = "https://kubernetes.default.svc"
      namespace = kubernetes_namespace_v1.monitoring.metadata[0].name
    }

    source {
      repo_url        = "https://charts.christianhuth.de"
      chart           = "umami"
      target_revision = "6.0.1"
      helm {
        values = yamlencode({
          ingress = {
            enabled = true
            hosts = [
              {
                host = "umami.stinkyboi.com"
                paths = [{
                  path     = "/"
                  pathType = "ImplementationSpecific"
                }]
              }
            ]
            tls = [{
              secretName = kubernetes_manifest.monitoring_certificate.manifest["spec"]["secretName"]
              hosts      = ["umami.stinkyboi.com"]
            }]
          }
          postgresql = {
            enabled = false
          }
          database = {
            databaseUrlKey = "umami_database_url"
            existingSecret = kubernetes_manifest.umami_secret.manifest.metadata.name
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

resource "kubernetes_manifest" "monitoring_certificate" {
  manifest = {
    apiVersion = "cert-manager.io/v1"
    kind       = "Certificate"
    metadata = {
      name      = "monitoring-ingressroute-certificate"
      namespace = kubernetes_namespace_v1.monitoring.metadata[0].name
    }
    spec = {
      secretName = "monitoring-certificate-secret"
      issuerRef = {
        name = "cloudflare-clusterissuer"
        kind = "ClusterIssuer"
      }
      dnsNames = [
        "grafana.stinkyboi.com",
        "prometheus.stinkyboi.com",
        "umami.stinkyboi.com"
      ]
    }
  }
}

resource "kubernetes_ingress_v1" "umami_tailscale_funnel" {
  metadata {
    name      = "umami-tailscale-funnel"
    namespace = kubernetes_namespace_v1.monitoring.metadata[0].name
    annotations = {
      "tailscale.com/funnel" = "true"
    }
  }
  spec {
    ingress_class_name = "tailscale"
    rule {
      host = "umami"
      http {
        path {
          path      = "/script.js"
          path_type = "Exact"
          backend {
            service {
              name = "umami"
              port {
                number = 3000
              }
            }
          }
        }
        path {
          path      = "/api/send"
          path_type = "Exact"
          backend {
            service {
              name = "umami"
              port {
                number = 3000
              }
            }
          }
        }
      }
    }
    tls {
      hosts = ["umami"]
    }
  }
}

resource "kubernetes_manifest" "umami_image_updater" {
  manifest = {
    apiVersion = "argocd-image-updater.argoproj.io/v1alpha1"
    kind       = "ImageUpdater"
    metadata = {
      name      = "umami-image-updater"
      namespace = kubernetes_namespace_v1.monitoring.metadata[0].name
    }
    spec = {
      namespace = "argocd"
      applicationRefs = [
        {
          namePattern = "umami"
          images = [
            {
              alias     = "umami"
              imageName = "ghcr.io/umami-software/umami:postgresql-v2"
              commonUpdateSettings = {
                updateStrategy = "digest"
              }
            }
          ]
        }
      ]
    }
  }
}
