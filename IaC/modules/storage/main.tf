resource "helm_release" "nfs_subdir_external_provisioner" {
  name       = "nfs-subdir-external-provisioner"
  repository = "https://kubernetes-sigs.github.io/nfs-subdir-external-provisioner"
  chart      = "nfs-subdir-external-provisioner"
  version    = "4.0.18"

  set = [
    {
      name  = "nfs.server"
      value = "10.1.0.2"
    },
    {
      name  = "nfs.path"
      value = "/k8sNFS"
    },
    {
      name  = "storageClass.defaultClass"
      value = "true"
    },
    {
      name  = "storageClass.accessModes"
      value = "ReadWriteMany"
    },
    {
      name  = "storageClass.name"
      value = "nfs-client"
    }
  ]
}

resource "helm_release" "nfs_media" {
  name       = "nfs-subdir-external-provisioner-media"
  repository = "https://kubernetes-sigs.github.io/nfs-subdir-external-provisioner"
  chart      = "nfs-subdir-external-provisioner"
  version    = "4.0.18"

  set = [
    {
      name  = "nfs.server"
      value = "10.1.0.2"
    },
    {
      name  = "nfs.path"
      value = "/Media"
    },
    {
      name  = "storageClass.accessModes"
      value = "ReadWriteMany"
    },
    {
      name  = "storageClass.name"
      value = "nfs-media"
    }
  ]
}

resource "helm_release" "nfs_database" {
  name       = "nfs-subdir-external-provisioner-database"
  repository = "https://kubernetes-sigs.github.io/nfs-subdir-external-provisioner"
  chart      = "nfs-subdir-external-provisioner"
  version    = "4.0.18"

  set = [
    {
      name  = "nfs.server"
      value = "10.1.0.2"
    },
    {
      name  = "nfs.path"
      value = "/k8sPostgres"
    },
    {
      name  = "storageClass.accessModes"
      value = "ReadWriteMany"
    },
    {
      name  = "storageClass.name"
      value = "nfs-database"
    }
  ]
}
