terraform {
  cloud {
    organization = "REPLACE-WITH-YOUR-ORG"
    workspaces { name = "novapay-stage" }
  }
}
