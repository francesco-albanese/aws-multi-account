# STEP 2: Create "terraform" IAM Role (Manual Console Steps)

**IMPORTANT**: Repeat these steps for EACH of the 5 accounts after account creation completes.

## Prerequisites
- Account IDs from `account-ids.json`
- Management account ID: 781928496898
- AWS Console access via awsclifranco-admin SSO profile

## For Each Account:

### 1. Switch to Target Account

1. AWS Console → Top-right account dropdown → **Switch Role**
2. **Account:** {account-id from account-ids.json}
3. **Role:** OrganizationAccountAccessRole
4. **Display Name:** {env}-admin (e.g., shared-services-admin, sandbox-admin)
5. Click **Switch Role**

### 2. Create "terraform" Role

1. Navigate to **IAM** service
2. Click **Roles** → **Create role**
3. **Trusted entity type:** AWS account
4. Select **Another AWS account**
5. **Account ID:** `781928496898` (management account)
6. Click **Next**
7. **Permissions policies:** Search and select `AdministratorAccess`
8. Click **Next**
9. **Role name:** `terraform`
10. **Description:** `Terraform CI/CD deployments`
11. **Tags (optional):**
    - Key: `managed_by`, Value: `terraform`
    - Key: `purpose`, Value: `infrastructure-as-code`
12. Click **Create role**

### 3. Verify Trust Policy

1. Click on the newly created **terraform** role
2. Go to **Trust relationships** tab
3. Verify the trust policy looks like this:

```json
{
  "Version": "2012-10-17",
  "Statement": [{
    "Effect": "Allow",
    "Principal": {"AWS": "arn:aws:iam::781928496898:root"},
    "Action": "sts:AssumeRole"
  }]
}
```

### 4. Test Assume Role (After All Accounts Done)

```bash
# Get account ID from account-ids.json
ACCOUNT_ID=$(jq -r '.["shared-services"]' account-ids.json)

# Test assume role
export AWS_PROFILE=awsclifranco-admin
aws sts assume-role \
  --role-arn "arn:aws:iam::${ACCOUNT_ID}:role/terraform" \
  --role-session-name test

# Should return temporary credentials
```

## Accounts to Process

1. shared-services
2. sandbox
3. staging
4. uat
5. production

## Checklist

- [ ] shared-services: terraform role created
- [ ] sandbox: terraform role created
- [ ] staging: terraform role created
- [ ] uat: terraform role created
- [ ] production: terraform role created
- [ ] All roles tested via AWS CLI

## Expected Time

~5 minutes per account = 25 minutes total
