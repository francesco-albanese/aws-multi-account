provider "aws" {
  region = var.region

  dynamic "assume_role" {
    for_each = var.account_id != "" ? [1] : []
    content {
      role_arn = "arn:aws:iam::${var.account_id}:role/terraform"
    }
  }

  default_tags {
    tags = {
      "franco:terraform_stack" = "aws-multi-account-sso"
      "franco:environment"     = var.account_name
      "franco:managed_by"      = "terraform"
    }
  }
}
