resource "kubernetes_manifest" "octobot_image_updater" {
  manifest = {
    apiVersion = "argocd-image-updater.argoproj.io/v1alpha1"
    kind       = "ImageUpdater"
    metadata = {
      name      = "argocd-image-updater"
      namespace = kubernetes_namespace_v1.argocd.metadata[0].name
    }
    spec = {
      namespace = "argocd"
      applicationRefs = [
        {
          namePattern = "octobot"
          images = [
            {
              alias     = "octobot"
              imageName = "drakkarsoftware/octobot:2.x"
              commonUpdateSettings = {
                updateStrategy = "semver"
              }
            }
          ]
        }
      ]
    }
  }
}
