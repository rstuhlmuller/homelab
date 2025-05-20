resource "helm_release" "nfs_subdir_external_provisioner" {
  name       = "nfs-subdir-external-provisioner"
  repository = "https://kubernetes-sigs.github.io/nfs-subdir-external-provisioner"
  chart      = "nfs-subdir-external-provisioner"
  version    = "4.0"

  set {
    name  = "nfs.server"
    value = "10.1.0.2"
  }
  set {
    name  = "nfs.path"
    value = "/k8sNFS"
  }
  set {
    name  = "storageClass.defaultClass"
    value = "true"
  }
  set {
    name  = "storageClass.accessModes"
    value = "ReadWriteMany"
  }
}
