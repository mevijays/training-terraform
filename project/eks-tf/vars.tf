variable "AWS_REGION" {
  default = "us-east-2"
}
variable "VPC_CIDR" {
  default = "192.168.0.0/16"
}
variable "cluster-name" {
  default = "eks-demo"
  type    = string
}
variable "public_subnets_cidr" {
  default = ["192.168.0.0/24", "192.168.1.0/24"]
}
variable "private_subnets_cidr" {
  default = ["192.168.2.0/24", "192.168.3.0/24"]
}
variable "node_group_name" {
  default = "eks-node-group"
  type    = string
}
variable "node_size" {
  default = ["t3.medium"]
}
variable "disk_size" {
  default = 20
}
variable "githubClientSecret" {
  default = "e94005726cf6d5d8887e9e7a322d4894e7d7ef55"

}
variable "msTeamsWebhook" {
  default = "https://mevijayin.webhook.office.com/webhookb2/6e2d665d-f61e-4972-8d79-bb031e4e804d@30c34ae5-d7d3-4f4c-92d2-3b116a8db4e7/IncomingWebhook/6badc587218f442b8cfd1f1e03a8bb08/98fcbe7f-b6d8-4229-9f6d-ff75143d871d"
}
variable "namespaceToWatch" {
  default = "default"
}
variable "dashboardHost" {
  default = "dashboard.devk8s.mylab.local"
  type    = string
}
variable "argourl" {
  default = "argo.devk8s.mylab.local"
  type    = string
}
variable "datadogKey" {
  default = "demoapikey"
  type    = string
}
variable "k8s_version" {
  default = "1.29"
}
variable "nsname" {
  default = "ns1"
  type    = string
}
variable "awsrole" {
  default = "role1"
  type    = string
}