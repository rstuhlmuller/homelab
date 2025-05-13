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
    name = "monitoring"
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
        value_files = ["values.yaml"]
        values      = yamlencode({})
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
