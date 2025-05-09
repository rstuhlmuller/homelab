resource "helm_release" "release" {
  name             = "argocd"
  chart            = "argo-cd"
  repository       = "https://argoproj.github.io/argo-helm"
  version          = "7.7.14"
  timeout          = "1500"
  namespace        = "argocd"
  create_namespace = true

  set {
    name  = "spec.type"
    value = "LoadBalancer"
  }
}
