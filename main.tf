terraform {
  cloud {
    organization = "liamstevens111"

    workspaces {
      name = "liam-infrastructure-example"
    }
  }

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.0"
    }
  }
}

provider "aws" {
  region = "us-east-1"
}
