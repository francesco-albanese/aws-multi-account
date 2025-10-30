output "shared_services_account_id" {
  description = "AWS account ID for shared-services account (use in Phase 0 terraform.tfvars)"
  value       = aws_organizations_account.shared_services.id
}

output "shared_services_account_arn" {
  description = "ARN of shared-services account"
  value       = aws_organizations_account.shared_services.arn
}

output "shared_services_email" {
  description = "Email address of shared-services account"
  value       = aws_organizations_account.shared_services.email
}

output "organization_account_access_role_arn" {
  description = "ARN of OrganizationAccountAccessRole in shared-services account"
  value       = "arn:aws:iam::${aws_organizations_account.shared_services.id}:role/${var.role_name}"
}

output "next_steps" {
  description = "Instructions for Phase 0"
  value       = <<-EOT

  ========================================
  Phase -1 Complete! Shared-Services Account Created
  ========================================

  Account ID: ${aws_organizations_account.shared_services.id}
  Email:      ${aws_organizations_account.shared_services.email}
  Role:       ${var.role_name}

  NEXT: Copy this Account ID to Phase 0 terraform.tfvars

  cd ../environmental

  Edit terraform.tfvars:
    shared_services_account_id = "${aws_organizations_account.shared_services.id}"

  Then run Phase 0 bootstrap.
  ========================================
  EOT
}
