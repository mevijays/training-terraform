terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "5.48.0"
    }
  }
  cloud {
    organization = "KRLABORG"

    workspaces {
      name = "cliws"
    }
  }
}
provider "aws" {
  region = var.AWS_REGION
  default_tags {
    tags = {
      Environment = "First lab"
      Owner       = "Vijay Kumar"
    }
  }
}
data "aws_eks_cluster" "example" {
  name = var.cluster-name
  depends_on = [
    aws_eks_cluster.aws_eks
  ]
}

data "aws_eks_cluster_auth" "example" {
  name = var.cluster-name
  depends_on = [
    aws_eks_cluster.aws_eks
  ]
}

provider "kubernetes" {
  host                   = data.aws_eks_cluster.example.endpoint
  cluster_ca_certificate = base64decode(data.aws_eks_cluster.example.certificate_authority[0].data)
  token                  = data.aws_eks_cluster_auth.example.token
}
provider "helm" {
  kubernetes {
    host                   = data.aws_eks_cluster.example.endpoint
    cluster_ca_certificate = base64decode(data.aws_eks_cluster.example.certificate_authority[0].data)
    token                  = data.aws_eks_cluster_auth.example.token
  }
}