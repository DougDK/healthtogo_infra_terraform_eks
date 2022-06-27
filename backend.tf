terraform {
  backend "local" {
    path = "~/Code/H2G/Infra/Terraform_EKS/"
  }

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 3.67"
    }
  }
}
