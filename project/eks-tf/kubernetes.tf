resource "null_resource" "download_yaml" {
  triggers {
    type  = "always"
  }
  provisioner "local-exec" {
    command = "curl -o deploy.yaml https://raw.githubusercontent.com/kubernetes/ingress-nginx/controller-v1.10.1/deploy/static/provider/aws/deploy.yaml"
  }
}
resource "kubernetes_manifest" "deployment" {
  manifest = filebase64sha256("deploy.yaml")
}
resource "helm_release" "metrics_server" {
  name       = "metrics-server"
  namespace  = "kube-system"
  repository = "https://olemarkus.github.io/metrics-server"
  chart      = "metrics-server"
  depends_on = [
    helm_release.nginx_ingress,
    aws_eks_cluster.aws_eks,
    aws_eks_node_group.node
  ]
}
resource "helm_release" "argocd" {
  depends_on = [
    helm_release.nginx_ingress,
    aws_eks_cluster.aws_eks,
    aws_eks_node_group.node
  ]
  name             = "argocd"
  namespace        = "argocd"
  create_namespace = true
  repository       = "https://argoproj.github.io/argo-helm"
  chart            = "argo-cd"
  set {
    name  = "server.ingress.enabled"
    value = "true"
  }
  set {
    name  = "server.ingress.ingressClassName"
    value = "nginx"
  }
  set {
    name  = "server.ingress.tls[0].secretName"
    value = "argotls"
  }
  set {
    name  = "server.ingress.https"
    value = "true"
  }
  set {
    name  = "server.ingress.hosts[0]"
    value = var.argourl
  }
  set {
    name  = "server.extraArgs[0]"
    value = "--insecure"
  }
  set {
    name  = "configs.secret.extra.dex\\.github\\.clientSecret"
    value = var.githubClientSecret
  }
  values = [
    file("charts/argocd/values.yaml"),
  ]
}

resource "helm_release" "kubewatch" {
  depends_on = [
    helm_release.nginx_ingress,
    aws_eks_cluster.aws_eks,
    aws_eks_node_group.node
  ]
  name             = "kubewatch"
  namespace        = "kube-system"
  create_namespace = true
  repository       = "https://charts.bitnami.com/bitnami"
  chart            = "kubewatch"
  set {
    name  = "slack.enabled"
    value = "false"
  }
  set {
    name  = "msteams.enabled"
    value = "true"
  }
  set {
    name  = "msteams.webhookurl"
    value = var.msTeamsWebhook
  }
  set {
    name  = "namespaceToWatch"
    value = var.namespaceToWatch
  }
  set {
    name  = "rbac.create"
    value = "true"
  }
}

resource "helm_release" "k8s_dashboard" {
  name             = "kubernetes-dashboard"
  namespace        = "kubernetes-dashboard"
  create_namespace = true
  repository       = "https://kubernetes.github.io/dashboard"
  chart            = "kubernetes-dashboard"
  depends_on = [
    helm_release.nginx_ingress,
    aws_eks_cluster.aws_eks,
    aws_eks_node_group.node
  ]
  set {
    name  = "ingress.enabled"
    value = "true"
  }
  set {
    name  = "ingress.hosts[0]"
    value = var.dashboardHost
  }
  set {
    name  = "ingress.tls[0].secretName"
    value = "dashboard-tls"
  }
  set {
    name  = "ingress.annotations\\.nginx\\.ingress\\.kubernetes\\.io/secure-backends"
    value = "true"
  }
}
resource "helm_release" "aws_calico" {
  depends_on = [
    aws_eks_cluster.aws_eks,
    aws_eks_node_group.node
  ]
  name       = "aws-calico"
  namespace  = "kube-system"
  repository = "https://aws.github.io/eks-charts"
  chart      = "aws-calico"
}

resource "helm_release" "aws_cloudwatch_metric" {
  depends_on = [
    aws_eks_cluster.aws_eks,
    aws_eks_node_group.node
  ]
  name             = "aws-cloudwatch-metric"
  namespace        = "aws-cloudwatch"
  create_namespace = true
  repository       = "https://aws.github.io/eks-charts"
  chart            = "aws-cloudwatch-metrics"
  set {
    name  = "clusterName"
    value = var.cluster-name
  }
}

resource "helm_release" "cert_manager" {
  depends_on = [
    aws_eks_cluster.aws_eks,
    aws_eks_node_group.node
  ]
  name             = "cert-manager"
  namespace        = "cert-manager"
  create_namespace = true
  repository       = "https://charts.jetstack.io"
  chart            = "cert-manager"
  version          = "v1.14.5"
}


