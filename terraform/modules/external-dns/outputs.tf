output "role_arn" {
  value = aws_iam_role.controller.arn
}

output "helm_release_name" {
  value = helm_release.this.name
}
