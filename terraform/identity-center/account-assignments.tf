# IAM Identity Center Account Assignments
# Assigns existing user to all accounts with both Admin and ReadOnly permission sets
resource "aws_ssoadmin_account_assignment" "assignments" {
  for_each = local.assignments

  instance_arn       = local.instance_arn
  permission_set_arn = aws_ssoadmin_permission_set.sets[each.value.permission_set].arn

  principal_id   = each.value.principal_id
  principal_type = "USER"

  target_id   = each.value.account_id
  target_type = "AWS_ACCOUNT"
}
