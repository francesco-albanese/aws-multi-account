# Implementation Guide - AWS Multi-Account SSO Setup

**Estimated Time**: 2-3 hours  
**Difficulty**: Intermediate  
**Cost**: ~$0-1/month

## Overview

This guide walks through setting up AWS multi-account architecture with IAM Identity Center (SSO) and Terraform state management. Follow phases sequentially.

---

## Phase 0: Bootstrap Infrastructure (Shared-Services)

**Goal**: Create shared-services account with S3/DynamoDB for Terraform state

**Duration**: 30 minutes

### Step 0.1: Prepare Email Addresses

You need 5 unique email addresses:

1. ✅ Management: albanesefrancesco.af@gmail.com (existing)
2. 🆕 Shared-Services: `francesco+shared-services@yourdomain.com`
3. 🆕 Sandbox: `francesco+sandbox@yourdomain.com`
4. 🆕 Staging: `francesco+staging@yourdomain.com`
5. 🆕 UAT: `francesco+uat@yourdomain.com`
6. 🆕 Production: `francesco+production@yourdomain.com`

**Note**: Gmail supports `+` aliases, so you can use your existing email

### Step 0.2: Enable AWS Organizations (if not already)

```bash
# Check if Organizations is enabled
aws organizations describe-organization

# If error, enable it:
aws organizations create-organization --feature-set ALL
```

### Step 0.3: Create Shared-Services Account (Manual - First Time)

**Option A: AWS Console**
1. Go to AWS Organizations
2. Click "Add an AWS account" → "Create an AWS account"
3. Enter:
   - Account name: `shared-services`
   - Email: `francesco+shared-services@yourdomain.com`
   - IAM role name: `OrganizationAccountAccessRole`
4. Wait for account creation (5-10 min)
5. Note the Account ID

**Option B: AWS CLI**
```bash
aws organizations create-account \
  --account-name shared-services \
  --email francesco+shared-services@yourdomain.com \
  --role-name OrganizationAccountAccessRole

# Check status
aws organizations describe-create-account-status \
  --create-account-request-id <request-id>
```

### Step 0.4: Configure Bootstrap Terraform

```bash
cd /Users/francescoalbanese/Documents/Development/aws-multi-account/bootstrap

# Copy example variables
cp terraform.tfvars.example terraform.tfvars

# Edit terraform.tfvars with your values
# - management_account_id
# - shared_services_account_id  
# - project_prefix (e.g., "francesco-aws")
```

### Step 0.5: Run Bootstrap (Creates S3 + DynamoDB + IAM)

```bash
cd bootstrap

# Initialize Terraform
terraform init

# Review plan
terraform plan

# Apply (creates resources in shared-services account)
terraform apply

# IMPORTANT: Save these outputs
terraform output -json > ../bootstrap-outputs.json
```

**What gets created:**
- S3 bucket with SSE-S3 encryption (FREE)
- DynamoDB table for state locking
- IAM role `terraform-state-access`
- Bucket policy for cross-account access

### Step 0.6: Create state.conf File

```bash
cd /Users/francescoalbanese/Documents/Development/aws-multi-account

# Bootstrap will output this file
cat state.conf
```

**Example state.conf:**
```hcl
region         = "eu-west-2"
bucket         = "francesco-aws-terraform-state-abc123"
encrypt        = true
dynamodb_table = "francesco-aws-terraform-locks"

assume_role = {
  role_arn     = "arn:aws:iam::123456789012:role/terraform-state-access"
  session_name = "terraform-state-access"
  external_id  = "terraform-state-access"
}
```

### Step 0.7: Test State Access

```bash
cd bootstrap

# Migrate local state to S3
terraform init -migrate-state -backend-config=../state.conf

# Verify state in S3
aws s3 ls s3://francesco-aws-terraform-state-abc123/ \
  --profile management \
  --region eu-west-2
```

✅ **Checkpoint**: S3 bucket created, state migrated successfully

---

## Phase 1: Foundation Setup (Manual AWS Console)

**Goal**: Enable IAM Identity Center in management account

**Duration**: 15 minutes

### Step 1.1: Enable IAM Identity Center

1. Login to AWS Console (management account)
2. Navigate to: **IAM Identity Center**
3. Click **Enable**
4. Choose identity source: **Identity Center directory** (default)
5. Wait for activation (~2 min)

### Step 1.2: Note Your SSO Portal URL

After enabling, you'll see:
- **AWS access portal URL**: `https://d-abc123xyz.awsapps.com/start`
- **Region**: `eu-west-2` (or your chosen region)

**Save these values** - you'll need them for CLI configuration.

### Step 1.3: Verify IAM Identity Center API Access

```bash
# Get SSO instance details
aws sso-admin list-instances

# Note the InstanceArn and IdentityStoreId
```

✅ **Checkpoint**: IAM Identity Center enabled, SSO URL noted

---

## Phase 2: Create Member Accounts

**Goal**: Create sandbox, staging, uat, production accounts

**Duration**: 30 minutes

### Step 2.1: Configure Organization Terraform

```bash
cd /Users/francescoalbanese/Documents/Development/aws-multi-account/organization

# Copy and edit variables
cp terraform.tfvars.example terraform.tfvars
```

**Edit terraform.tfvars:**
```hcl
management_account_id = "781928496898"

accounts = {
  sandbox = {
    email = "francesco+sandbox@yourdomain.com"
  }
  staging = {
    email = "francesco+staging@yourdomain.com"
  }
  uat = {
    email = "francesco+uat@yourdomain.com"
  }
  production = {
    email = "francesco+production@yourdomain.com"
  }
}
```

### Step 2.2: Initialize with Remote State

```bash
cd organization

# Initialize with remote state backend
terraform init -backend-config=../state.conf

# Review plan
terraform plan
```

### Step 2.3: Create Accounts

```bash
# Apply - creates 4 accounts
terraform apply

# IMPORTANT: Save account IDs
terraform output -json > ../member-accounts.json
```

**This creates:**
- 4 AWS accounts
- OrganizationAccountAccessRole in each
- Outputs account IDs for next phase

### Step 2.4: Verify Account Creation

```bash
# List all accounts
aws organizations list-accounts

# Test assume role to sandbox
aws sts assume-role \
  --role-arn "arn:aws:iam::<sandbox-id>:role/OrganizationAccountAccessRole" \
  --role-session-name test
```

✅ **Checkpoint**: 4 member accounts created and accessible

---

## Phase 3: Configure IAM Identity Center

**Goal**: Setup users, groups, permission sets, and assignments

**Duration**: 45 minutes

### Step 3.1: Configure Identity Center Terraform

```bash
cd /Users/francescoalbanese/Documents/Development/aws-multi-account/identity-center

# Copy and edit variables
cp terraform.tfvars.example terraform.tfvars
```

**Edit terraform.tfvars:**
```hcl
# From Phase 1
sso_instance_arn    = "arn:aws:sso:::instance/ssoins-abc123"
identity_store_id   = "d-abc123xyz"

# From Phase 2 (member-accounts.json)
account_ids = {
  sandbox    = "111111111111"
  staging    = "222222222222"
  uat        = "333333333333"
  production = "444444444444"
}

# Users to create
users = {
  awsclifranco = {
    user_name   = "awsclifranco"
    given_name  = "Francesco"
    family_name = "Albanese"
    email       = "albanesefrancesco.af@gmail.com"
  }
}

# Groups
groups = {
  AllowedUsers = {
    description = "Users allowed to access AWS accounts"
    members     = ["awsclifranco"]
  }
}
```

### Step 3.2: Initialize with Remote State

```bash
cd identity-center

# Initialize
terraform init -backend-config=../state.conf

# Review plan
terraform plan
```

### Step 3.3: Apply Identity Center Configuration

```bash
# Apply in stages
terraform apply -target=module.users
terraform apply -target=module.groups
terraform apply -target=module.permission_sets
terraform apply
```

**This creates:**
- User: awsclifranco
- Group: AllowedUsers
- Permission Sets: Admin, ReadOnly
- Account assignments for all 4 accounts

### Step 3.4: Set User Password (Manual)

1. Go to IAM Identity Center console
2. Users → awsclifranco
3. Click "Reset password"
4. Choose "Send email" or "Generate one-time password"
5. Save the password

✅ **Checkpoint**: SSO configured, users can access accounts

---

## Phase 4: Testing & Validation

**Goal**: Verify SSO access via console and CLI

**Duration**: 20 minutes

### Step 4.1: Test SSO Portal (Web)

1. Go to your SSO URL: `https://d-abc123xyz.awsapps.com/start`
2. Login as: `awsclifranco`
3. Enter password
4. You should see 4 accounts (sandbox, staging, uat, production)
5. For each account, you should see:
   - Admin role
   - ReadOnly role
6. Click on any role → opens AWS Console

### Step 4.2: Configure AWS CLI for SSO

```bash
# Configure SSO profile
aws configure sso

# Prompts:
# SSO session name: my-sso
# SSO start URL: https://d-abc123xyz.awsapps.com/start
# SSO region: eu-west-2
# SSO registration scopes: sso:account:access
```

### Step 4.3: Create CLI Profiles

Edit `~/.aws/config`:

```ini
[sso-session my-sso]
sso_start_url = https://d-abc123xyz.awsapps.com/start
sso_region = eu-west-2
sso_registration_scopes = sso:account:access

[profile sandbox-admin]
sso_session = my-sso
sso_account_id = 111111111111
sso_role_name = Admin
region = eu-west-2

[profile sandbox-readonly]
sso_session = my-sso
sso_account_id = 111111111111
sso_role_name = ReadOnly
region = eu-west-2

[profile staging-admin]
sso_session = my-sso
sso_account_id = 222222222222
sso_role_name = Admin
region = eu-west-2

[profile production-admin]
sso_session = my-sso
sso_account_id = 444444444444
sso_role_name = Admin
region = eu-west-2
```

### Step 4.4: Test CLI Access

```bash
# Login via SSO
aws sso login --profile sandbox-admin

# Test access
aws sts get-caller-identity --profile sandbox-admin
aws s3 ls --profile sandbox-admin

# Test ReadOnly (should fail on write ops)
aws s3 mb s3://test-bucket --profile sandbox-readonly
# Should get AccessDenied

# Test other profiles
aws sts get-caller-identity --profile production-admin
```

### Step 4.5: Verify Cross-Account State Access

```bash
# From any phase directory
cd organization
terraform plan --var-file=terraform.tfvars

# Should work without errors using remote state
```

✅ **Checkpoint**: SSO working via console and CLI

---

## Phase 5: Documentation & Cleanup

### Step 5.1: Document Your Setup

Create a private note with:
- SSO Portal URL
- Account IDs for each environment
- State bucket name
- IAM role ARNs

### Step 5.2: Secure Credentials

```bash
# Remove any temporary credentials
rm -f ~/.aws/credentials.backup

# Verify no hardcoded keys in Terraform
grep -r "AKIA" .
grep -r "aws_access_key" .
```

### Step 5.3: Git Setup (Optional - for Portfolio)

```bash
cd /Users/francescoalbanese/Documents/Development/aws-multi-account

# Initialize git
git init

# Create .gitignore
cat > .gitignore << 'EOF'
# Terraform
**/.terraform/
**/.terraform.lock.hcl
**/terraform.tfstate
**/terraform.tfstate.backup
**/.terraform.tfstate.lock.info
**/terraform.tfvars
**/bootstrap-outputs.json
**/member-accounts.json

# Sensitive files
state.conf
**/secrets/
**/*.pem
**/*.key

# OS
.DS_Store
EOF

# Initial commit
git add .
git commit -m "Initial AWS multi-account SSO setup"

# Push to GitHub (make repo private initially)
```

---

## Troubleshooting

### Issue: "Access Denied" when assuming role

**Solution**: Check trust policy in target account's IAM role

```bash
aws iam get-role \
  --role-name OrganizationAccountAccessRole \
  --profile sandbox-admin
```

### Issue: State bucket not accessible

**Solution**: Verify assume role permissions

```bash
# Test assume role manually
aws sts assume-role \
  --role-arn "arn:aws:iam::<shared-services>:role/terraform-state-access" \
  --role-session-name test
```

### Issue: IAM Identity Center not showing accounts

**Solution**: Check account assignments

```bash
cd identity-center
terraform state list | grep account_assignment
```

---

## Next Steps

1. ✅ Setup complete - you now have multi-account SSO
2. 🎯 Consider adding:
   - Service Control Policies (SCPs)
   - CloudTrail centralized logging
   - AWS Config for compliance
   - GuardDuty for security monitoring
3. 📚 Showcase this on GitHub portfolio
4. 🔄 Use this pattern for future projects

---

## Cost Tracking

Monitor your costs:

```bash
# Check S3 storage usage
aws s3 ls s3://your-state-bucket --recursive --summarize

# Check DynamoDB usage
aws dynamodb describe-table \
  --table-name your-terraform-locks \
  --query 'Table.ItemCount'
```

**Expected**: <$1/month (likely $0 with free tier)

---

## Support

If you encounter issues:
1. Check terraform.log: `export TF_LOG=DEBUG`
2. Review AWS CloudTrail for API errors
3. Validate IAM policies with Policy Simulator

---

**Congratulations!** 🎉  
You now have a production-ready AWS multi-account setup with SSO and centralized state management.
