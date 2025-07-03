resource "kubernetes_namespace" "monitoring" {
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
      namespace = kubernetes_namespace.monitoring.metadata[0].name
    }

    source {
      repo_url        = "https://prometheus-community.github.io/helm-charts"
      chart           = "prometheus"
      target_revision = "27.13.0"
      helm {
        parameter {
          name  = "alertmanager.enabled"
          value = "false"
        }
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

resource "argocd_application" "grafana" {
  metadata {
    name = "grafana"
  }

  spec {
    project = "default"
    destination {
      server    = "https://kubernetes.default.svc"
      namespace = kubernetes_namespace.monitoring.metadata[0].name
    }

    source {
      repo_url        = "https://grafana.github.io/helm-charts"
      chart           = "grafana"
      target_revision = "9.0"
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
      namespace = kubernetes_namespace.monitoring.metadata[0].name
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
