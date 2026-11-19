###############################333
#
# IAM User
#
###############################333

resource "aws_iam_user" "admin" {
  name          = "administrator"
  path          = "/admin/"
  force_destroy = true
}

resource "aws_iam_account_password_policy" "admin" {
  minimum_password_length        = 14
  require_lowercase_characters   = true
  require_numbers                = true
  require_uppercase_characters   = true
  require_symbols                = true
  allow_users_to_change_password = true
  max_password_age               = 15
  password_reuse_prevention      = 24
}

resource "aws_iam_user_login_profile" "admin" {
  user                    = aws_iam_user.admin.name
  pgp_key                 = var.admin_gpg_key
  password_reset_required = true
  password_length         = 20
}

###############################333
#
# IAM ADMIN GROUP
#
###############################333


resource "aws_iam_group" "administrators" {
  name = "Admins"
}

resource "aws_iam_group_policy_attachment" "administrators" {
  group      = aws_iam_group.administrators.name
  policy_arn = "arn:aws:iam::aws:policy/AdministratorAccess"
}

resource "aws_iam_group_membership" "administrators" {
  name = "admin-members"

  users = [
    aws_iam_user.admin.name
  ]

  group = aws_iam_group.administrators.name
}
