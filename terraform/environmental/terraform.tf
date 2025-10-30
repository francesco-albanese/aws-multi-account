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

  # No backend block initially - uses local state
  # After resources created, will migrate to S3
  # my company leaves backend "s3" empty as the bucket is specified only in state.conf
  # Uncomment after Step 5 migration:
  # backend "s3" {
  #   key = "environmental/terraform.tfstate"
  #   # bucket, region, assume_role from -backend-config
  # }
}
