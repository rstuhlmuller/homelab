locals {
}

stack "argocd" {
  source = "${dirname(find_in_parent_folders("root.hcl"))}/stacks/argocd"
  path   = "argocd"

  values = {
    version = "dev"
  }
}
