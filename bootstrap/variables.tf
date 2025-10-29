variable "aws_region" {
  description = "AWS region for resources"
  type        = string
  default     = "eu-west-2"
}

variable "management_account_id" {
  description = "AWS Management Account ID"
  type        = string
  
  validation {
    condition     = can(regex("^[0-9]{12}$", var.management_account_id))
    error_message = "Management account ID must be a 12-digit number"
  }
}

variable "shared_services_account_id" {
  description = "AWS Shared Services Account ID (created manually first)"
  type        = string
  
  validation {
    condition     = can(regex("^[0-9]{12}$", var.shared_services_account_id))
    error_message = "Shared services account ID must be a 12-digit number"
  }
}

variable "project_prefix" {
  description = "Prefix for resource names (lowercase, alphanumeric, hyphens only)"
  type        = string
  default     = "my-aws"
  
  validation {
    condition     = can(regex("^[a-z0-9-]+$", var.project_prefix))
    error_message = "Project prefix must contain only lowercase letters, numbers, and hyphens"
  }
}

variable "state_access_role_name" {
  description = "Name of IAM role for cross-account state access"
  type        = string
  default     = "terraform-state-access"
}

variable "external_id" {
  description = "External ID for assuming state access role (adds security)"
  type        = string
  default     = "terraform-state-access"
  sensitive   = true
}
