output "instance_arn" {
  description = "IAM Identity Center instance ARN"
  value       = local.instance_arn
}

output "identity_store_id" {
  description = "Identity Store ID"
  value       = local.identity_store_id
}

output "sso_start_url" {
  description = "AWS SSO start URL"
  value       = "https://${split("/", local.instance_arn)[1]}.awsapps.com/start"
}

output "permission_set_arns" {
  description = "Map of permission set names to ARNs"
  value       = { for k, v in aws_ssoadmin_permission_set.sets : k => v.arn }
}

output "account_assignments" {
  description = "Summary of account assignments"
  value = {
    for key, assignment in local.assignments : key => {
      account_id     = assignment.account_id
      permission_set = assignment.permission_set
      user           = var.existing_user.username
    }
  }
}

output "summary" {
  description = "Deployment summary"
  value = {
    user            = var.existing_user.username
    permission_sets = length(aws_ssoadmin_permission_set.sets)
    assignments     = length(aws_ssoadmin_account_assignment.assignments)
    accounts        = length(distinct([for a in var.account_assignments : a.account_id]))
  }
}

output "aws_cli_profiles" {
  description = "Example AWS CLI SSO profile configuration"
  value = <<-EOT
    Add to ~/.aws/config:

    [profile sandbox-admin]
    sso_start_url = ${local.instance_arn != "" ? "https://${split("/", local.instance_arn)[1]}.awsapps.com/start" : "PLACEHOLDER"}
    sso_region = eu-west-2
    sso_account_id = 645275603781
    sso_role_name = Admin
    region = eu-west-2

    [profile sandbox-readonly]
    sso_start_url = ${local.instance_arn != "" ? "https://${split("/", local.instance_arn)[1]}.awsapps.com/start" : "PLACEHOLDER"}
    sso_region = eu-west-2
    sso_account_id = 645275603781
    sso_role_name = ReadOnly
    region = eu-west-2

    # Repeat pattern for staging, uat, production...
  EOT
}
