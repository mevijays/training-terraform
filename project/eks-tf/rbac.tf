resource "kubernetes_namespace" "ns" {
  metadata {
    name = var.nsname
  }
}

resource "kubernetes_cluster_role" "clusterreader" {
  metadata {
    name = "clusterreader"
  }

  rule {
    api_groups = ["*"]
    resources  = ["*"]
    verbs      = ["get", "list", "watch"]
  }

}

resource "kubernetes_cluster_role" "clusterrole1" {
  metadata {
    name = "clusterrole1"
  }

  rule {
    api_groups = [""]
    resources  = ["persistentvolumes"]
    verbs      = ["get", "list", "watch", "create", "update", "delete", "patch"]
  }
  rule {
    api_groups = [""]
    resources  = ["nodes"]
    verbs      = ["get", "list", "watch"]
  }
  rule {
    api_groups = ["storage.k8s.io"]
    resources  = ["storageclasses"]
    verbs      = ["get", "list", "watch"]
  }
}

resource "kubernetes_cluster_role" "clusterrole2" {
  metadata {
    name = "clusterrole2"
  }

  rule {
    api_groups = ["*"]
    resources  = ["*"]
    verbs      = ["*"]
  }

}

resource "kubernetes_cluster_role_binding" "crb1" {
  metadata {
    name = "crb1"
  }
  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind      = "ClusterRole"
    name      = "clusterrole1"
  }
  subject {
    kind      = "User"
    name      = var.awsrole
    api_group = "rbac.authorization.k8s.io"
  }
}

resource "kubernetes_cluster_role_binding" "clusterreader" {
  metadata {
    name = "clusterreader"
  }
  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind      = "ClusterRole"
    name      = "clusterreader"
  }
  subject {
    kind      = "User"
    name      = var.awsrole
    api_group = "rbac.authorization.k8s.io"
  }
}


// use count to make this in count of namespaces given. e.g.  var.nsname[*]

resource "kubernetes_role_binding" "nsadmin" {
  metadata {
    name      = "nsadmin"
    namespace = var.nsname
  }
  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind      = "ClusterRole"
    name      = "clusterrole2"
  }
  subject {
    kind      = "User"
    name      = var.awsrole
    api_group = "rbac.authorization.k8s.io"
  }
}

resource "kubernetes_role_binding" "nsreader" {
  metadata {
    name      = "nsreader"
    namespace = var.nsname
  }
  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind      = "ClusterRole"
    name      = "clusterreader"
  }
  subject {
    kind      = "User"
    name      = var.awsrole
    api_group = "rbac.authorization.k8s.io"
  }
}
