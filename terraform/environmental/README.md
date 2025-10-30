# Phase 0: Bootstrap State Infrastructure

**Duration:** 20 minutes
**Cost:** $0/month (free tier)
**State:** Local → S3 (migration)

## Purpose

Creates centralized Terraform state infrastructure in shared-services account:
- S3 bucket with SSE-S3 encryption (FREE)
- DynamoDB table for state locking
- IAM role for cross-account state access
- Generates `state.conf` for subsequent phases

## Prerequisites

- Phase -1 completed (shared-services account exists)
- shared_services_account_id from Phase -1 output
- Management account credentials (awsclifranco-admin profile)
- AdministratorAccess permissions

## Usage

```bash
cd terraform/environmental

# Create terraform.tfvars from example
cp terraform.tfvars.example terraform.tfvars

# Edit: paste shared_services_account_id from Phase -1
nano terraform.tfvars

# Initialize Terraform
terraform init

# Review what will be created
terraform plan

# Create state infrastructure (takes ~30 seconds)
terraform apply

# Generate state.conf for Phase 2+
terraform output -raw state_conf > ../state.conf

# Verify state.conf
cat ../state.conf
```

## State Migration

After resources are created, migrate local state to S3:

```bash
# 1. Uncomment backend "s3" block in terraform.tf

# 2. Re-initialize with backend migration
terraform init -migrate-state -backend-config=../state.conf

# Answer "yes" to both prompts:
#   - Migrate workspaces to s3? yes
#   - Copy existing state to new backend? yes

# 3. Verify migration
aws s3 ls s3://$(terraform output -raw state_bucket_name)/ --region eu-west-2

# 4. Local state should be empty
ls -la terraform.tfstate*
```

## Outputs

- `state_bucket_name` - S3 bucket for state
- `locks_table_name` - DynamoDB for locking
- `terraform_state_access_role_arn` - Cross-account role
- `state_conf` - Backend config (save to ../state.conf)
- `next_steps` - Migration instructions

## Resources Created

- `random_id.state_bucket_suffix` - Unique bucket suffix
- `random_id.external_id` - Cross-account security token
- `aws_s3_bucket.terraform_state` - State storage (8 total resources)
- `aws_dynamodb_table.terraform_locks` - State locking
- `aws_iam_role.terraform_state_access` - Cross-account access
- `aws_iam_role_policy.terraform_state_access` - Permissions policy

Total: 8 resources

## Next Phase

After migration complete:

**Phase 1: Foundation (Manual)**
- Enable AWS Organizations (if not done)
- Enable IAM Identity Center
- See: [plans/phase-1-foundation.md](../../plans/phase-1-foundation.md)

## Rollback

```bash
# Destroy infrastructure (CAUTION: deletes state storage)
terraform destroy -auto-approve

# Remove state.conf
rm ../state.conf
```

## Verification

```bash
# Test assume role
aws sts assume-role \
  --role-arn $(terraform output -raw terraform_state_access_role_arn) \
  --role-session-name test \
  --external-id $(terraform output -raw external_id)

# Verify encryption
aws s3api get-bucket-encryption \
  --bucket $(terraform output -raw state_bucket_name) \
  --region eu-west-2

# Expected: "SSEAlgorithm": "AES256"
```
