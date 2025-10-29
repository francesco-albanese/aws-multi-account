output "account_ids" {
  description = "Map of account names to IDs"
  value = {
    for name, account in aws_organizations_account.accounts : name => account.id
  }
}

output "account_arns" {
  description = "Map of account names to ARNs"
  value = {
    for name, account in aws_organizations_account.accounts : name => account.arn
  }
}

output "account_emails" {
  description = "Map of account names to email addresses"
  value = {
    for name, account in aws_organizations_account.accounts : name => account.email
  }
}

output "management_account_id" {
  description = "Management account ID"
  value       = data.aws_caller_identity.current.account_id
}

output "organization_id" {
  description = "AWS Organization ID"
  value       = data.aws_organizations_organization.org.id
}

output "organization_arn" {
  description = "AWS Organization ARN"
  value       = data.aws_organizations_organization.org.arn
}

output "account_summary" {
  description = "Summary of created accounts"
  value = {
    for name, account in aws_organizations_account.accounts : name => {
      id    = account.id
      email = account.email
      arn   = account.arn
    }
  }
}

output "next_steps" {
  description = "Next steps after organization setup"
  value = <<-EOT
  
  ✅ Member Accounts Created!
  
  Accounts:
  %{for name, account in aws_organizations_account.accounts~}
  - ${name}: ${account.id} (${account.email})
  %{endfor~}
  
  Next Steps:
  
  1. Save account IDs:
     terraform output -json > ../member-accounts.json
  
  2. Update bootstrap trust policy (optional):
     - Add member account IDs to terraform-state-access role
     - This allows member accounts to access state bucket
  
  3. Proceed to Phase 3 (Identity Center):
     cd ../identity-center
  
  4. Test account access:
     aws sts assume-role \
       --role-arn "arn:aws:iam::<account-id>:role/OrganizationAccountAccessRole" \
       --role-session-name test
  EOT
}
