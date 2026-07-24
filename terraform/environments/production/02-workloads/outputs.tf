output "namespace" {
  value = module.workloads.namespace
}

output "app_image" {
  value = "${data.aws_ecr_repository.app.repository_url}:${var.image_tag}"
}

output "load_balancer_hostname" {
  description = "Public ELB hostname serving the URL shortener. Open http://<hostname>/"
  value       = module.workloads.load_balancer_hostname
}
