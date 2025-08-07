resource "kubernetes_namespace" "litellm" {
  metadata {
    name = "litellm"
  }
}

resource "argocd_application" "litellm" {
  metadata {
    name = "litellm"
    annotations = {
      "argocd-image-updater.argoproj.io/image-list"              = "litellm=ghcr.io/berriai/litellm:main-latest"
      "argocd-image-updater.argoproj.io/litellm.update-strategy" = "latest"
    }
  }

  spec {
    project = "default"
    destination {
      server    = "https://kubernetes.default.svc"
      namespace = kubernetes_namespace.litellm.metadata[0].name
    }

    source {
      repo_url        = "https://github.com/BerriAI/litellm.git"
      path            = "deploy/charts/litellm-helm"
      target_revision = "HEAD"
      helm {
        parameter {
          name  = "migrationJob.enabled"
          value = "false"
        }
        parameter {
          name  = "db.useExisting"
          value = "true"
        }
        values = yamlencode({
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

resource "kubernetes_manifest" "litellm_tls" {
  manifest = {
    apiVersion = "cert-manager.io/v1"
    kind       = "Certificate"
    metadata = {
      name      = "litellm-tls"
      namespace = kubernetes_namespace.litellm.metadata[0].name
    }
    spec = {
      secretName = "litellm-tls"
      issuerRef = {
        name = "cloudflare-clusterissuer"
        kind = "ClusterIssuer"
      }
      dnsNames = [
        "litellm.stinkyboi.com"
      ]
    }
  }
}
