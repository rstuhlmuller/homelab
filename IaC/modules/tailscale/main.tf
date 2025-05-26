resource "kubernetes_namespace" "tailscale" {
  metadata {
    name = "tailscale"
    labels = {
      "pod-security.kubernetes.io/enforce" = "privileged"
      "pod-security.kubernetes.io/audit"   = "privileged"
      "pod-security.kubernetes.io/warn"    = "privileged"
    }
  }
}

resource "argocd_application" "tailscale" {
  metadata {
    name = "tailscale"
  }

  spec {
    project = "default"
    destination {
      server    = "https://kubernetes.default.svc"
      namespace = kubernetes_namespace.tailscale.metadata[0].name
    }
    source {
      repo_url        = "https://pkgs.tailscale.com/helmcharts"
      chart           = "tailscale-operator"
      target_revision = "1.82.5"
      helm {
        parameter {
          name  = "oauth.clientID"
          value = aws_ssm_parameter.oauth_secret["oauth_client_id"].value
        }
        parameter {
          name  = "oauth.clientSecret"
          value = aws_ssm_parameter.oauth_secret["oauth_client_secret"].value
        }
      }
    }
    source {
      repo_url = "https://github.com/rstuhlmuller/homelab.git"
      path     = "tailscale"
    }
    sync_policy {
      automated {
        prune     = true
        self_heal = true
      }
    }
  }
}
