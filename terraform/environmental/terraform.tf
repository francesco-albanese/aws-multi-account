terraform {
  required_version = ">= 1.13.4"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 6.18.0"
    }
    random = {
      source  = "hashicorp/random"
      version = ">= 3.7.2"
    }
  }

  # Backend configuration provided via -backend-config=../../state.conf
  backend "s3" {
    key = "environmental/terraform.tfstate"
    # bucket, region, assume_role from -backend-config
  }
}
