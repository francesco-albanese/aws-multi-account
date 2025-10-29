# Organization Phase - Create Member Accounts

Creates AWS member accounts (sandbox, staging, uat, production) within AWS Organizations.

## What Gets Created

- 4 AWS Accounts in AWS Organizations
- OrganizationAccountAccessRole in each account (automatic)
- Outputs account IDs for Identity Center phase

## Prerequisites

1. Phase 0 (bootstrap) completed
2. state.conf file exists in parent directory
3. Unique email addresses for each account

## Quick Start

```bash
# 1. Copy example variables
cp terraform.tfvars.example terraform.tfvars

# 2. Edit with your email addresses
nano terraform.tfvars

# 3. Initialize with remote state
terraform init -backend-config=../state.conf

# 4. Plan
terraform plan

# 5. Apply (creates 4 accounts)
terraform apply

# 6. Save outputs
terraform output -json > ../member-accounts.json
```

## Account Creation Time

Each account takes ~5-10 minutes to create. Total: ~20-40 minutes.

## Outputs

- `account_ids`: Map of account names to IDs
- `account_emails`: Map of account names to emails
- `management_account_id`: Your management account ID

## Next Steps

After successful account creation:
1. Save account IDs: `terraform output -json > ../member-accounts.json`
2. Proceed to Phase 3 (identity-center/)
