variable "region" {
  description = "AWS region for infrastructure"
  type        = string
  default     = "eu-west-2"
}

variable "account_id" {
  description = "AWS Shared-Services account ID"
  type        = string
}

variable "account_name" {
  description = "The name of the account (shared-services)"
  type        = string
  default     = "shared-services"
}

variable "project_prefix" {
  description = "Prefix for resource naming (e.g., 'franco-multi-account-sso')"
  type        = string
}

variable "enable_versioning" {
  description = "Enable S3 bucket versioning"
  type        = bool
  default     = true
}