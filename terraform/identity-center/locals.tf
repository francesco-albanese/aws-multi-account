locals {
  instance_arn      = tolist(data.aws_ssoadmin_instances.main.arns)[0]
  identity_store_id = tolist(data.aws_ssoadmin_instances.main.identity_store_ids)[0]

  # All assignments use the same existing user
  assignments = {
    for idx, assignment in var.account_assignments :
    "${assignment.account_id}-${assignment.permission_set}" => {
      account_id       = assignment.account_id
      permission_set   = assignment.permission_set
      principal_id     = var.existing_user.user_id
      principal_type   = "USER"
    }
  }
}
