resource "kubernetes_manifest" "cloudflare_clusterissuer" {
  manifest = {
    apiVersion = "cert-manager.io/v1"
    kind       = "ClusterIssuer"
    metadata = {
      name = "cloudflare-clusterissuer"
    }
    spec = {
      acme = {
        email  = "rodman@stuhlmuller.net"
        server = "https://acme-v02.api.letsencrypt.org/directory"
        privateKeySecretRef = {
          name = "cloudflare-clusterissuer-account-key"
        }
        solvers = [
          {
            dns01 = {
              cloudflare = {
                apiTokenSecretRef = {
                  name = "cloudflare-api-key-secret"
                  key  = "api_key"
                }
              }
            }
          }
        ]
      }
    }
  }
}
