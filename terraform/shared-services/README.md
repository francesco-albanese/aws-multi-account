# Phase -1: Create Shared-Services Account

**Duration:** 10 minutes
**Cost:** $0
**State:** Local (no backend)

## Purpose

Creates the shared-services AWS account via Terraform before Phase 0 bootstrap.
This account will host the centralized Terraform state infrastructure.

## Prerequisites

- AWS Organizations enabled
- Management account credentials (awsclifranco-admin profile)
- AdministratorAccess permissions

## Usage

```bash
cd terraform/shared-services

# Create terraform.tfvars from example
cp terraform.tfvars.example terraform.tfvars

# Review and customize if needed
cat terraform.tfvars

# Initialize Terraform
terraform init

# Review what will be created
terraform plan

# Create shared-services account (takes 5-10 minutes)
terraform apply

# Capture the account ID
terraform output shared_services_account_id
```

## Outputs

The apply will output:
- `shared_services_account_id` - Use this in Phase 0 terraform.tfvars
- `organization_account_access_role_arn` - Auto-created role for cross-account access
- `next_steps` - Instructions for Phase 0

## Next Phase

Copy the Account ID to Phase 0:

```bash
cd ../environmental
nano terraform.tfvars  # Add: shared_services_account_id = "123456789012"
```

Then proceed with Phase 0 bootstrap.

## State Management

- Local state: `terraform.tfstate` (gitignored)
- No remote backend (this creates the remote backend)
- State contains only the account resource

## Rollback

```bash
# CAUTION: This will suspend (not close) the account
terraform destroy

# To permanently close: set close_on_deletion = true first
```

**Note:** AWS accounts cannot be reopened once closed. Default is suspend only.
