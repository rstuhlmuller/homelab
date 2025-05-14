dependencies {
  paths = ["${dirname(find_in_parent_folders("region.hcl"))}/argocd"]
}

generate "argocd_provider" {
  path      = "argocd_provider.tf"
  if_exists = "overwrite"
  contents  = <<EOF
provider "argocd" {
  use_local_config = true
}
EOF
}
