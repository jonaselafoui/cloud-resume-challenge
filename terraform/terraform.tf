terraform {
  cloud {
    organization = "jonas-ma"
    workspaces {
      name = "personal-website"
    }
  }

  required_providers {
    aws = {
      source = "hashicorp/aws"
      version = "6.12.0"
    }
  }
}