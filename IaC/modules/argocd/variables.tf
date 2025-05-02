variable "tags" {
  type    = map(string)
  default = {}
}
variable "name" {}
variable "chart" {}
variable "repository" {}
variable "chart_version" {}
variable "timeout" {}
variable "namespace" {}
variable "create_namespace" {}
