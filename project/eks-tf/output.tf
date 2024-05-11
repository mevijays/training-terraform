data "kubernetes_secret" "example" {
  depends_on = [helm_release.argocd]
  metadata {
    name      = "argocd-initial-admin-secret"
    namespace = "argocd"
  }
}
data "kubernetes_service" "ingressSVC" {
  depends_on = [helm_release.nginx_ingress]
  metadata {
    name      = "nginx-ingress-ingress-nginx-controller"
    namespace = "ingress-nginx"
  }
}
output "endpoint" {
  value = aws_eks_cluster.aws_eks.endpoint
}
output "kubeconfig-certificate-authority-data" {
  value = aws_eks_cluster.aws_eks.certificate_authority[0].data
}
output "identity-oidc-issuer" {
  value = aws_eks_cluster.aws_eks.identity[0].oidc[0].issuer
}
output "argo-admin-user-password" {
  value     = data.kubernetes_secret.example.data.password
  sensitive = true
}
output "ingress-external-ip" {
  value = data.kubernetes_service.ingressSVC.status[0].load_balancer[0].ingress[0].hostname
}