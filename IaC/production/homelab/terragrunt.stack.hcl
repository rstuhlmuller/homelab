unit "metallb" {
  source = "git::https://github.com/rstuhlmuller/terragrunt-catalog.git//units/argocd_application?ref=v0.1.0"
  path   = "metallb"

  values = {
    name      = "metallb"
    namespace = "metallb"
    chart     = "metallb"
    version   = "0.1.0"
  }
}

unit "storage" {
  source = "../../modules/storage"
}

unit "traefik" {
  source = "../../modules/traefik"
}

unit "cert-manager" {
  source = "../../modules/cert-manager"
}
