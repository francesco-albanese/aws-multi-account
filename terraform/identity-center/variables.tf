variable "region" {
  description = "AWS region for IAM Identity Center"
  type        = string
  default     = "eu-west-2"
}

variable "project_prefix" {
  description = "Prefix for resource naming"
  type        = string
}

variable "existing_user" {
  description = "Existing SSO user to assign to accounts"
  type = object({
    username = string
    user_id  = string
  })
}

variable "permission_sets" {
  description = "Map of permission sets to create"
  type = map(object({
    description          = string
    session_duration     = optional(string, "PT8H")
    managed_policy_arns  = optional(list(string), [])
    inline_policy        = optional(string, null)
    relay_state          = optional(string, null)
  }))
}

variable "account_assignments" {
  description = "List of account assignments (user -> account -> permission set)"
  type = list(object({
    account_id     = string
    permission_set = string
  }))
}

variable "account_ids" {
  description = "Map of environment names to AWS account IDs"
  type        = map(string)
}
