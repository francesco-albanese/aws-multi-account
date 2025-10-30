provider "aws" {
  region = var.region

  # Default provider for management account
}

provider "aws" {
  alias  = "shared_services"
  region = var.region

  assume_role {
    role_arn     = "arn:aws:iam::${var.shared_services_account_id}:role/OrganizationAccountAccessRole"
    session_name = "terraform-bootstrap"
  }

  default_tags {
    tags =  {
      "franco:terraform_stack" = "aws-multi-account-sso"
      "franco:managed_by"      = "terraform"
      "franco:environment"     = var.account_name
    }
  }
}
