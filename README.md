# AWS Multi-Account SSO Setup with Terraform

Complete guide for setting up AWS multi-account architecture with IAM Identity Center (SSO) using Terraform, with centralized state management and zero-cost encryption.

## Architecture Overview

```
Management Account (francesco-lbn)
├── IAM Identity Center (SSO)
├── Users/Groups (awsclifranco in AllowedUsers)
└── AWS Organizations

Shared-Services Account
├── S3 Bucket (terraform-state) - SSE-S3 encryption (FREE)
├── DynamoDB Table (state locking)
└── IAM Role: terraform-state-access

Member Accounts
├── sandbox
├── staging
├── uat
└── production
```

## Prerequisites

- AWS Management Account (you have: francesco-lbn / 781928496898)
- AWS CLI configured with management account credentials
- Terraform >= 1.5.0
- Unique email addresses for each account (5 total)

## Project Structure

```
aws-multi-account/
├── README.md                     # This file
├── IMPLEMENTATION.md             # Step-by-step guide
├── state.conf.example           # Backend config template
├── bootstrap/                    # Phase 0 - Run first
│   ├── README.md
│   ├── main.tf
│   ├── variables.tf
│   ├── outputs.tf
│   └── terraform.tfvars.example
├── organization/                 # Phase 2 - Create accounts
│   ├── README.md
│   ├── backend.tf
│   ├── main.tf
│   ├── variables.tf
│   ├── outputs.tf
│   └── terraform.tfvars.example
├── identity-center/              # Phase 3 - SSO setup
│   ├── README.md
│   ├── backend.tf
│   ├── main.tf
│   ├── users.tf
│   ├── groups.tf
│   ├── permission-sets.tf
│   ├── account-assignments.tf
│   ├── variables.tf
│   ├── outputs.tf
│   └── terraform.tfvars.example
└── docs/
    ├── sso-cli-setup.md
    ├── troubleshooting.md
    └── cost-optimization.md
```

## Implementation Phases

### Phase 0: Bootstrap (Shared-Services Setup)
- Create shared-services account
- Setup S3 + DynamoDB for state
- Create cross-account IAM role
- **Cost**: ~$0/month (free tier)

### Phase 1: Foundation (Manual)
- Enable AWS Organizations (if not already)
- Enable IAM Identity Center
- Note SSO portal URL

### Phase 2: Member Accounts
- Create sandbox/staging/uat/production accounts
- Configure with Terraform
- **Cost**: No additional cost

### Phase 3: IAM Identity Center
- Create users and groups
- Setup permission sets (Admin, ReadOnly)
- Assign to accounts

### Phase 4: Testing & Validation
- Test SSO portal access
- Configure AWS CLI with SSO
- Verify cross-account access

## Quick Start

1. Read IMPLEMENTATION.md for detailed steps
2. Start with Phase 0 (bootstrap/)
3. Follow phases sequentially
4. Each phase has its own README.md

## Key Features

✅ **Zero Cost Encryption**: SSE-S3 (AES256) instead of KMS  
✅ **Centralized State**: Single S3 bucket for all TF state  
✅ **Cross-Account Access**: Secure assume role pattern  
✅ **GitOps Ready**: Can be version controlled and showcased  
✅ **Best Practices**: Follows AWS Well-Architected Framework  

## State Management

All Terraform state stored in shared-services account:
- Bucket: `yourorg-terraform-state-<uuid>`
- Region: `eu-west-2`
- Encryption: SSE-S3 (AES256) - **FREE**
- Locking: DynamoDB - **FREE tier eligible**

## Security

- SSE-S3 encryption at rest (FREE)
- Bucket versioning enabled
- Public access blocked
- Cross-account access via IAM roles
- External ID for additional security
- MFA can be required (optional)

## Cost Estimate

- S3 Storage: ~$0.023/GB/month (first 50GB free)
- S3 Requests: Minimal (free tier covers)
- DynamoDB: Free tier (25GB, 25 RCU/WCU)
- **Total**: ~$0-1/month

## Next Steps

Read `IMPLEMENTATION.md` to begin setup.
