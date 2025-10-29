terraform {
  required_version = ">= 1.5.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
    random = {
      source  = "hashicorp/random"
      version = "~> 3.6"
    }
  }

  # No backend configured - this is the bootstrap
  # State will be local until migrated to S3
}

# Default provider - management account
provider "aws" {
  region = var.aws_region

  default_tags {
    tags = {
      ManagedBy   = "Terraform"
      Project     = var.project_prefix
      Environment = "bootstrap"
      Phase       = "0-bootstrap"
    }
  }
}

# Provider for shared-services account
provider "aws" {
  alias  = "shared_services"
  region = var.aws_region

  assume_role {
    role_arn     = "arn:aws:iam::${var.shared_services_account_id}:role/OrganizationAccountAccessRole"
    session_name = "terraform-bootstrap"
  }

  default_tags {
    tags = {
      ManagedBy   = "Terraform"
      Project     = var.project_prefix
      Environment = "shared-services"
      Phase       = "0-bootstrap"
    }
  }
}

# Random suffix for globally unique bucket name
resource "random_id" "suffix" {
  byte_length = 4
}

# S3 Bucket for Terraform State
resource "aws_s3_bucket" "terraform_state" {
  provider = aws.shared_services

  bucket = "${var.project_prefix}-terraform-state-${random_id.suffix.hex}"

  tags = {
    Name        = "Terraform State Bucket"
    Purpose     = "Backend storage for all Terraform state files"
    Encryption  = "SSE-S3"
    Versioning  = "Enabled"
  }
}

# Enable versioning
resource "aws_s3_bucket_versioning" "terraform_state" {
  provider = aws.shared_services

  bucket = aws_s3_bucket.terraform_state.id

  versioning_configuration {
    status = "Enabled"
  }
}

# Enable SSE-S3 encryption (FREE - no KMS costs)
resource "aws_s3_bucket_server_side_encryption_configuration" "terraform_state" {
  provider = aws.shared_services

  bucket = aws_s3_bucket.terraform_state.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"  # SSE-S3 - FREE!
    }
  }
}

# Block public access
resource "aws_s3_bucket_public_access_block" "terraform_state" {
  provider = aws.shared_services

  bucket = aws_s3_bucket.terraform_state.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

# Lifecycle policy - keep state versions for 90 days
resource "aws_s3_bucket_lifecycle_configuration" "terraform_state" {
  provider = aws.shared_services

  bucket = aws_s3_bucket.terraform_state.id

  rule {
    id     = "expire-old-versions"
    status = "Enabled"

    noncurrent_version_expiration {
      noncurrent_days = 90
    }
  }

  rule {
    id     = "expire-delete-markers"
    status = "Enabled"

    expiration {
      expired_object_delete_marker = true
    }
  }
}

# DynamoDB Table for State Locking
resource "aws_dynamodb_table" "terraform_locks" {
  provider = aws.shared_services

  name         = "${var.project_prefix}-terraform-locks"
  billing_mode = "PAY_PER_REQUEST"  # Free tier eligible
  hash_key     = "LockID"

  attribute {
    name = "LockID"
    type = "S"
  }

  point_in_time_recovery {
    enabled = true
  }

  tags = {
    Name    = "Terraform State Lock Table"
    Purpose = "State locking for all Terraform operations"
  }
}

# IAM Role for Cross-Account State Access
resource "aws_iam_role" "terraform_state_access" {
  provider = aws.shared_services

  name        = var.state_access_role_name
  description = "Role for cross-account Terraform state access"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          AWS = [
            "arn:aws:iam::${var.management_account_id}:root",
            # Add member accounts after they're created
            # These will be added in Phase 2
          ]
        }
        Action = "sts:AssumeRole"
        Condition = {
          StringEquals = {
            "sts:ExternalId" = var.external_id
          }
        }
      }
    ]
  })

  tags = {
    Name    = "Terraform State Access Role"
    Purpose = "Cross-account access to Terraform state"
  }
}

# IAM Policy for State Access
resource "aws_iam_role_policy" "terraform_state_access" {
  provider = aws.shared_services

  name = "terraform-state-access-policy"
  role = aws_iam_role.terraform_state_access.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "S3StateAccess"
        Effect = "Allow"
        Action = [
          "s3:ListBucket",
          "s3:GetObject",
          "s3:PutObject",
          "s3:DeleteObject"
        ]
        Resource = [
          aws_s3_bucket.terraform_state.arn,
          "${aws_s3_bucket.terraform_state.arn}/*"
        ]
      },
      {
        Sid    = "DynamoDBStateLocking"
        Effect = "Allow"
        Action = [
          "dynamodb:GetItem",
          "dynamodb:PutItem",
          "dynamodb:DeleteItem",
          "dynamodb:DescribeTable"
        ]
        Resource = aws_dynamodb_table.terraform_locks.arn
      }
    ]
  })
}

# S3 Bucket Policy for Additional Security
resource "aws_s3_bucket_policy" "terraform_state" {
  provider = aws.shared_services

  bucket = aws_s3_bucket.terraform_state.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "AllowTerraformStateAccessRole"
        Effect = "Allow"
        Principal = {
          AWS = aws_iam_role.terraform_state_access.arn
        }
        Action = [
          "s3:ListBucket",
          "s3:GetObject",
          "s3:PutObject",
          "s3:DeleteObject"
        ]
        Resource = [
          aws_s3_bucket.terraform_state.arn,
          "${aws_s3_bucket.terraform_state.arn}/*"
        ]
      },
      {
        Sid    = "EnforceSSES3Encryption"
        Effect = "Deny"
        Principal = "*"
        Action = "s3:PutObject"
        Resource = "${aws_s3_bucket.terraform_state.arn}/*"
        Condition = {
          StringNotEquals = {
            "s3:x-amz-server-side-encryption" = "AES256"
          }
        }
      },
      {
        Sid    = "DenyInsecureTransport"
        Effect = "Deny"
        Principal = "*"
        Action = "s3:*"
        Resource = [
          aws_s3_bucket.terraform_state.arn,
          "${aws_s3_bucket.terraform_state.arn}/*"
        ]
        Condition = {
          Bool = {
            "aws:SecureTransport" = "false"
          }
        }
      }
    ]
  })
}
