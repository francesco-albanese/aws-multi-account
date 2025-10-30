# Random suffix for global bucket uniqueness
resource "random_id" "state_bucket_suffix" {
  byte_length = 4
}

# S3 bucket for Terraform state
resource "aws_s3_bucket" "terraform_state" {
  bucket = local.state_bucket_name

  lifecycle {
    prevent_destroy = false
  }

  tags = {
    Name        = "Terraform State Bucket"
    Description = "Centralized Terraform state storage"
  }
}

# S3 bucket versioning
resource "aws_s3_bucket_versioning" "terraform_state" {
  bucket = aws_s3_bucket.terraform_state.id

  versioning_configuration {
    status = var.enable_versioning ? "Enabled" : "Suspended"
  }
}

# S3 bucket encryption - SSE-S3 (FREE)
resource "aws_s3_bucket_server_side_encryption_configuration" "terraform_state" {
  bucket = aws_s3_bucket.terraform_state.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256" # SSE-S3 (FREE) not SSE-KMS
    }
  }
}

# Block all public access
resource "aws_s3_bucket_public_access_block" "terraform_state" {
  bucket = aws_s3_bucket.terraform_state.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

# DynamoDB table for state locking
resource "aws_dynamodb_table" "terraform_locks" {
  name         = local.locks_table_name
  billing_mode = "PAY_PER_REQUEST" # Free tier eligible
  hash_key     = "LockID"

  attribute {
    name = "LockID"
    type = "S"
  }

  lifecycle {
    prevent_destroy = false
  }

  tags = {
    Name        = "Terraform State Locks"
    Description = "State locking for Terraform operations"
  }
}
