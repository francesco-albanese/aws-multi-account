# Get current AWS account (management account)
data "aws_caller_identity" "current" {}

# Get AWS Organization
data "aws_organizations_organization" "org" {}

# Create member accounts
resource "aws_organizations_account" "accounts" {
  for_each = var.accounts

  name      = each.key
  email     = each.value.email
  role_name = "OrganizationAccountAccessRole"

  # Prevent accidental deletion
  lifecycle {
    prevent_destroy = false  # Set to true in production
  }

  tags = {
    Name        = each.key
    Environment = each.key
    ManagedBy   = "Terraform"
  }
}

# Optional: Create OUs (commented out - add if needed)
# resource "aws_organizations_organizational_unit" "environments" {
#   name      = "Environments"
#   parent_id = data.aws_organizations_organization.org.roots[0].id
# }

# Optional: Move accounts to OUs (commented out)
# resource "aws_organizations_organizational_unit" "sandbox" {
#   name      = "Sandbox"
#   parent_id = aws_organizations_organizational_unit.environments.id
# }
