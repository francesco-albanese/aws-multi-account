terraform {
  required_version = ">= 1.13.4"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 6.18.0"
    }
  }

  # No backend block - uses local state
  # This is Phase -1: account creation before bootstrap
}
