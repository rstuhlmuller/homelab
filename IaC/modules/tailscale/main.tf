resource "kubernetes_namespace" "tailscale" {
  metadata {
    name = "tailscale"
  }
}

resource "aws_ssm_parameter" "oauth_secret" {
  for_each = toset(["oauth_client_id", "oauth_client_secret"])
  name     = "/homelab/tailscale/${each.key}"
  type     = "SecureString"
  value    = "update_me"
  lifecycle {
    ignore_changes = [value]
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
      helm {
        parameter {
          name  = "oauth.clientId"
          value = aws_ssm_parameter.oauth_secret["oauth_client_id"].value
        }
        parameter {
          name  = "oauth.clientSecret"
          value = aws_ssm_parameter.oauth_secret["oauth_client_secret"].value
        }
      }
      repo_url        = "https://pkgs.tailscale.com/helmcharts"
      chart           = "tailscale-operator"
      target_revision = "1.82.5"
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
