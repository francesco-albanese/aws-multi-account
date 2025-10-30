variable "region" {
  description = "AWS region for infrastructure"
  type        = string
  default     = "eu-west-2"
}

variable "shared_services_email" {
  description = "Email address for shared-services account"
  type        = string
}

variable "role_name" {
  description = "IAM role name for cross-account access"
  type        = string
  default     = "OrganizationAccountAccessRole"
}

variable "close_on_deletion" {
  description = "Close account on Terraform destroy (cannot be reopened)"
  type        = bool
  default     = false
}

variable "account_name" {
  description = "The name of the account"
  type        = string
}