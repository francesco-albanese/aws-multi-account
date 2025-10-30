output "state_bucket_name" {
  description = "S3 bucket name for Terraform state"
  value       = aws_s3_bucket.terraform_state.id
}

output "state_bucket_arn" {
  description = "S3 bucket ARN"
  value       = aws_s3_bucket.terraform_state.arn
}

output "locks_table_name" {
  description = "DynamoDB table name for state locking"
  value       = aws_dynamodb_table.terraform_locks.name
}

output "locks_table_arn" {
  description = "DynamoDB table ARN"
  value       = aws_dynamodb_table.terraform_locks.arn
}

output "terraform_state_access_role_arn" {
  description = "IAM role ARN for cross-account state access"
  value       = aws_iam_role.terraform_state_access.arn
}

output "external_id" {
  description = "External ID for assume role"
  value       = local.external_id
  sensitive   = true
}

output "region" {
  description = "AWS region"
  value       = var.region
}

# Generate state.conf content for subsequent phases
output "state_conf" {
  description = "Backend configuration for subsequent phases (save to ../state.conf)"
  value       = <<-EOT
region         = "${var.region}"
bucket         = "${aws_s3_bucket.terraform_state.id}"
encrypt        = true
dynamodb_table = "${aws_dynamodb_table.terraform_locks.name}"

assume_role = {
  role_arn     = "${aws_iam_role.terraform_state_access.arn}"
  session_name = "terraform-state-access"
  external_id  = "${local.external_id}"
}
EOT
  sensitive   = true
}

output "next_steps" {
  description = "Instructions for state migration"
  value       = <<-EOT

  ========================================
  Phase 0 Complete! State Infrastructure Created
  ========================================

  S3 Bucket:       ${aws_s3_bucket.terraform_state.id}
  DynamoDB Table:  ${aws_dynamodb_table.terraform_locks.name}
  IAM Role:        ${aws_iam_role.terraform_state_access.arn}

  NEXT STEPS:

  1. Generate state.conf:
     terraform output -raw state_conf > ../state.conf

  2. Uncomment backend block in terraform.tf

  3. Migrate local state to S3:
     terraform init -migrate-state -backend-config=../state.conf

  4. Verify migration:
     aws s3 ls s3://${aws_s3_bucket.terraform_state.id}/ --region ${var.region}

  ========================================
  EOT
}
