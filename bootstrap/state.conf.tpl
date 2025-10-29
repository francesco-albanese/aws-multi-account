region         = "${region}"
bucket         = "${bucket}"
encrypt        = true
dynamodb_table = "${dynamodb_table}"

assume_role = {
  role_arn     = "${role_arn}"
  session_name = "terraform-state-access"
  external_id  = "${external_id}"
}
