variable "region" {
  description = "AWS region for infrastructure"
  type        = string
  default     = "eu-west-2"
}

variable "management_account_id" {
  description = "AWS Management account ID"
  type        = string
}

variable "shared_services_account_id" {
  description = "AWS Shared-Services account ID (from Phase -1 output)"
  type        = string
}

variable "project_prefix" {
  description = "Prefix for resource naming (e.g., 'francesco-aws')"
  type        = string
}

variable "enable_versioning" {
  description = "Enable S3 bucket versioning"
  type        = bool
  default     = true
}

variable "prevent_destroy" {
  description = "Enable prevent_destroy lifecycle (set false for dev)"
  type        = bool
  default     = false
}

variable "account_name" {
  description = "The name of the account"
  type        = string
}