region = "eu-west-2"

# Existing SSO user (from Identity Center)
# This will be imported, not created
existing_user = {
  username = "awsclifranco"
  user_id  = "66b27244-d0b1-7082-4558-5dca47aab2aa"
}

# Permission Sets (only Admin and ReadOnly)
permission_sets = {
  "Admin" = {
    description = "Full administrative access"
    managed_policy_arns = [
      "arn:aws:iam::aws:policy/AdministratorAccess"
    ]
    session_duration = "PT8H"
  }
  "ReadOnly" = {
    description = "Read-only access"
    managed_policy_arns = [
      "arn:aws:iam::aws:policy/ReadOnlyAccess"
    ]
    session_duration = "PT4H"
  }
}

# Account Assignments - User gets both Admin and ReadOnly on all accounts
# In SSO portal, you'll see each account with 2 role options
account_assignments = [
  # Sandbox
  {
    account_id     = "645275603781"
    permission_set = "Admin"
  },
  {
    account_id     = "645275603781"
    permission_set = "ReadOnly"
  },
  # Shared Services
  {
    account_id     = "088994864650"
    permission_set = "Admin"
  },
  {
    account_id     = "088994864650"
    permission_set = "ReadOnly"
  },
  # Staging
  {
    account_id     = "208318252599"
    permission_set = "Admin"
  },
  {
    account_id     = "208318252599"
    permission_set = "ReadOnly"
  },
  # UAT
  {
    account_id     = "393766496546"
    permission_set = "Admin"
  },
  {
    account_id     = "393766496546"
    permission_set = "ReadOnly"
  },
  # Production
  {
    account_id     = "165835313193"
    permission_set = "Admin"
  },
  {
    account_id     = "165835313193"
    permission_set = "ReadOnly"
  },
]
