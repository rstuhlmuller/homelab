resource "helm_release" "argocd" {
  name             = var.name
  chart            = var.chart
  repository       = var.repository
  version          = var.chart_version
  timeout          = var.timeout
  namespace        = var.namespace
  create_namespace = var.create_namespace
}
