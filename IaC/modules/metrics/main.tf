resource "kubernetes_namespace" "metrics" {
  metadata {
    name = "metrics-server"
    labels = {
      "pod-security.kubernetes.io/enforce" = "privileged"
      "pod-security.kubernetes.io/audit"   = "privileged"
      "pod-security.kubernetes.io/warn"    = "privileged"
    }
  }
}

resource "helm_release" "release" {
  name       = "metrics-server"
  chart      = "metrics-server"
  repository = "https://kubernetes-sigs.github.io/metrics-server/"
  version    = "3.13"
  namespace  = kubernetes_namespace.metrics.metadata[0].name
  set = [
    {
      name  = "args"
      value = "{--kubelet-insecure-tls,--kubelet-preferred-address-types=InternalIP,Hostname,InternalDNS,ExternalDNS,ExternalIP}"
    }
  ]
}
