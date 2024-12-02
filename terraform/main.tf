terraform {
  cloud {

    organization = "nk57xx"

    workspaces {
      name = "MVP-backend"
    }
  }
}
# Imports current account id
data "aws_caller_identity" "current" {}
