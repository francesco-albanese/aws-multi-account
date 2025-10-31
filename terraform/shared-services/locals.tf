locals {
  # Generate random suffix for global uniqueness
  bucket_suffix = random_id.state_bucket_suffix.hex

  # S3 bucket name (globally unique)
  state_bucket_name = "${var.project_prefix}-terraform-state-${local.bucket_suffix}"

  # DynamoDB table name
  locks_table_name = "${var.project_prefix}-terraform-locks"
}
