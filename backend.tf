terraform {
  backend "local" {
    path = "~/code/h2g/terraform.tfstate"
  }

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 3.67"
    }
  }
}
