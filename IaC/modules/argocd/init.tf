locals {
  tags = merge(
    var.tags,
    {
      Module = "self/argocd"
    }
  )
}
