output "state_bucket_name" {
  description = "S3 bucket name for Terraform state"
  value       = aws_s3_bucket.terraform_state.id
}

output "state_bucket_arn" {
  description = "ARN of S3 state bucket"
  value       = aws_s3_bucket.terraform_state.arn
}

output "locks_table_name" {
  description = "DynamoDB table name for state locking"
  value       = aws_dynamodb_table.terraform_locks.id
}

output "locks_table_arn" {
  description = "ARN of DynamoDB locks table"
  value       = aws_dynamodb_table.terraform_locks.arn
}

output "state_conf" {
  description = "Backend configuration for subsequent phases (save to ../state.conf)"
  value       = <<-EOT
bucket         = "${aws_s3_bucket.terraform_state.id}"
key            = "REPLACE_WITH_PHASE_KEY/terraform.tfstate"
region         = "${var.region}"
dynamodb_table = "${aws_dynamodb_table.terraform_locks.id}"
encrypt        = true
EOT
}

output "next_steps" {
  description = "Instructions for next phases"
  value       = <<-EOT

========================================
Phase 0 Complete! State Infrastructure Created
========================================

S3 Bucket:     ${aws_s3_bucket.terraform_state.id}
DynamoDB:      ${aws_dynamodb_table.terraform_locks.id}
Region:        ${var.region}

NEXT: Save state configuration for other phases

terraform output -raw state_conf > ../state.conf

Then configure backend in other phases using:
terraform init -backend-config=../state.conf
========================================
EOT
}
