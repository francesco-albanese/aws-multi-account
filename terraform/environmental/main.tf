# Random suffix for global bucket uniqueness
resource "random_id" "state_bucket_suffix" {
  byte_length = 4
}

# Random external ID for cross-account security
resource "random_id" "external_id" {
  byte_length = 16
}

# S3 bucket for Terraform state
resource "aws_s3_bucket" "terraform_state" {
  provider = aws.shared_services

  bucket = local.state_bucket_name

  lifecycle {
    prevent_destroy = var.prevent_destroy
  }

  tags = {
    Name        = "Terraform State Bucket"
    Description = "Centralized Terraform state storage"
  }
}

# S3 bucket versioning
resource "aws_s3_bucket_versioning" "terraform_state" {
  provider = aws.shared_services

  bucket = aws_s3_bucket.terraform_state.id

  versioning_configuration {
    status = var.enable_versioning ? "Enabled" : "Suspended"
  }
}

# S3 bucket encryption - SSE-S3 (FREE)
resource "aws_s3_bucket_server_side_encryption_configuration" "terraform_state" {
  provider = aws.shared_services

  bucket = aws_s3_bucket.terraform_state.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256" # SSE-S3 (FREE) not SSE-KMS
    }
  }
}

# Block all public access
resource "aws_s3_bucket_public_access_block" "terraform_state" {
  provider = aws.shared_services

  bucket = aws_s3_bucket.terraform_state.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

# DynamoDB table for state locking
resource "aws_dynamodb_table" "terraform_locks" {
  provider = aws.shared_services

  name         = local.locks_table_name
  billing_mode = "PAY_PER_REQUEST" # Free tier eligible
  hash_key     = "LockID"

  attribute {
    name = "LockID"
    type = "S"
  }

  lifecycle {
    prevent_destroy = var.prevent_destroy
  }

  tags = {
    Name        = "Terraform State Locks"
    Description = "State locking for Terraform operations"
  }
}

# IAM role for cross-account state access
resource "aws_iam_role" "terraform_state_access" {
  provider = aws.shared_services

  name = local.state_access_role_name

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          AWS = "arn:aws:iam::${var.management_account_id}:root"
        }
        Action = "sts:AssumeRole"
        Condition = {
          StringEquals = {
            "sts:ExternalId" = local.external_id
          }
        }
      }
    ]
  })

  tags = {
    Name        = "Terraform State Access"
    Description = "Cross-account role for Terraform state operations"
  }
}

# IAM policy for state access
resource "aws_iam_role_policy" "terraform_state_access" {
  provider = aws.shared_services

  name = "terraform-state-access"
  role = aws_iam_role.terraform_state_access.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "s3:ListBucket",
          "s3:GetBucketVersioning"
        ]
        Resource = aws_s3_bucket.terraform_state.arn
      },
      {
        Effect = "Allow"
        Action = [
          "s3:GetObject",
          "s3:PutObject",
          "s3:DeleteObject"
        ]
        Resource = "${aws_s3_bucket.terraform_state.arn}/*"
      },
      {
        Effect = "Allow"
        Action = [
          "dynamodb:GetItem",
          "dynamodb:PutItem",
          "dynamodb:DeleteItem"
        ]
        Resource = aws_dynamodb_table.terraform_locks.arn
      }
    ]
  })
}
