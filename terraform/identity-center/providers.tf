provider "aws" {
  region = var.region

  default_tags {
    tags = {
      "franco:terraform_stack" = "aws-multi-account-sso"
      "franco:environment"     = "management"
      "franco:managed_by"      = "terraform"
    }
  }
}
