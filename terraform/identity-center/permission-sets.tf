# IAM Identity Center Permission Sets
resource "aws_ssoadmin_permission_set" "sets" {
  for_each = var.permission_sets

  name             = each.key
  description      = each.value.description
  instance_arn     = local.instance_arn
  session_duration = each.value.session_duration
  relay_state      = each.value.relay_state
}

# Attach AWS managed policies
resource "aws_ssoadmin_managed_policy_attachment" "managed" {
  for_each = {
    for item in flatten([
      for ps_name, ps_config in var.permission_sets : [
        for policy_arn in ps_config.managed_policy_arns : {
          key        = "${ps_name}:${replace(policy_arn, "/", "_")}"
          ps_name    = ps_name
          policy_arn = policy_arn
        }
      ]
    ]) : item.key => item
  }

  instance_arn       = local.instance_arn
  permission_set_arn = aws_ssoadmin_permission_set.sets[each.value.ps_name].arn
  managed_policy_arn = each.value.policy_arn
}

# Attach inline policies
resource "aws_ssoadmin_permission_set_inline_policy" "inline" {
  for_each = {
    for ps_name, ps_config in var.permission_sets :
    ps_name => ps_config if ps_config.inline_policy != null
  }

  instance_arn       = local.instance_arn
  permission_set_arn = aws_ssoadmin_permission_set.sets[each.key].arn
  inline_policy      = each.value.inline_policy
}
