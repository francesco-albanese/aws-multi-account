# Bootstrap Phase - Shared-Services Account Setup

This phase creates the foundational infrastructure for Terraform state management.

## What Gets Created

- AWS Account: `shared-services`
- S3 Bucket for Terraform state (SSE-S3 encrypted)
- DynamoDB Table for state locking
- IAM Role for cross-account state access
- S3 Bucket Policy
- state.conf file for other phases

## Prerequisites

1. Shared-services account created in AWS Organizations
2. AWS CLI configured with management account credentials
3. Terraform >= 1.5.0 installed

## Quick Start

```bash
# 1. Copy example variables
cp terraform.tfvars.example terraform.tfvars

# 2. Edit terraform.tfvars with your account IDs
nano terraform.tfvars

# 3. Initialize
terraform init

# 4. Plan
terraform plan

# 5. Apply
terraform apply

# 6. Save outputs
terraform output -json > ../bootstrap-outputs.json
terraform output -raw state_conf > ../state.conf
```

## Outputs

- `state_bucket_name`: S3 bucket for Terraform state
- `state_bucket_arn`: ARN of S3 bucket
- `dynamodb_table_name`: DynamoDB table for state locking
- `terraform_state_access_role_arn`: IAM role ARN for cross-account access
- `state_conf`: Complete state.conf content (save to ../state.conf)

## Cost

- S3: ~$0.023/GB/month (first 50GB free)
- DynamoDB: FREE tier (25GB, 25 RCU/WCU)
- **Total**: ~$0/month (free tier eligible)

## Next Steps

After successful bootstrap:
1. Save `state.conf` file: `terraform output -raw state_conf > ../state.conf`
2. Proceed to Phase 2 (organization/)
