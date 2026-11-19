output "username" {
  value = aws_iam_user_login_profile.admin.user
}

output "password" {
  value     = aws_iam_user_login_profile.admin.encrypted_password
  sensitive = true
}
