variable "aws_region" {
  description = "AWS region"
  type        = string
  default     = "eu-west-2"
}

variable "project_prefix" {
  description = "Project prefix for tagging"
  type        = string
  default     = "my-aws"
}

variable "accounts" {
  description = "Map of account names to configuration"
  type = map(object({
    email = string
  }))

  validation {
    condition = alltrue([
      for k, v in var.accounts : can(regex("^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\\.[a-zA-Z]{2,}$", v.email))
    ])
    error_message = "All accounts must have valid email addresses"
  }
}
