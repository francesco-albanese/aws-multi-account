output "state_bucket_name" {
  description = "Name of S3 bucket for Terraform state"
  value       = aws_s3_bucket.terraform_state.id
}

output "state_bucket_arn" {
  description = "ARN of S3 bucket for Terraform state"
  value       = aws_s3_bucket.terraform_state.arn
}

output "dynamodb_table_name" {
  description = "Name of DynamoDB table for state locking"
  value       = aws_dynamodb_table.terraform_locks.name
}

output "dynamodb_table_arn" {
  description = "ARN of DynamoDB table for state locking"
  value       = aws_dynamodb_table.terraform_locks.arn
}

output "terraform_state_access_role_arn" {
  description = "ARN of IAM role for cross-account state access"
  value       = aws_iam_role.terraform_state_access.arn
}

output "terraform_state_access_role_name" {
  description = "Name of IAM role for cross-account state access"
  value       = aws_iam_role.terraform_state_access.name
}

output "shared_services_account_id" {
  description = "Shared Services Account ID"
  value       = var.shared_services_account_id
}

output "state_conf" {
  description = "Complete state.conf file content - save this to ../state.conf"
  value = templatefile("${path.module}/state.conf.tpl", {
    region         = var.aws_region
    bucket         = aws_s3_bucket.terraform_state.id
    dynamodb_table = aws_dynamodb_table.terraform_locks.name
    role_arn       = aws_iam_role.terraform_state_access.arn
    external_id    = var.external_id
  })
}

output "next_steps" {
  description = "Next steps after bootstrap"
  value = <<-EOT
  
  ✅ Bootstrap Complete!
  
  Next Steps:
  
  1. Save state.conf file:
     terraform output -raw state_conf > ../state.conf
  
  2. Migrate bootstrap state to S3:
     terraform init -migrate-state -backend-config=../state.conf
  
  3. Proceed to Phase 2:
     cd ../organization
     
  4. Test state access:
     aws s3 ls s3://${aws_s3_bucket.terraform_state.id}/
  
  Resources Created:
  - S3 Bucket: ${aws_s3_bucket.terraform_state.id}
  - DynamoDB Table: ${aws_dynamodb_table.terraform_locks.name}
  - IAM Role: ${aws_iam_role.terraform_state_access.name}
  
  Cost: ~$0/month (free tier eligible)
  EOT
}
