output "instance_id" {
  value = aws_instance.this.id
}

output "public_ip" {
  value = aws_instance.this.public_ip
}

output "ssh_command" {
  value = "ssh -i eks-bastion.pem ubuntu@${aws_instance.this.public_ip}"
}

output "role_arn" {
  description = "IAM role kubectl authenticates as (EKS cluster admin via access entry)."
  value       = aws_iam_role.this.arn
}
