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

output "hostname_load_balancer_hostname" {
  description = "ALB hostname behind the host-based Ingress (external-dns aliases ingress_hostname to it)."
  value       = module.workloads.hostname_load_balancer_hostname
}

output "ingress_hostname" {
  description = "DNS name external-dns publishes, e.g. http://apin1.dongzh.store/"
  value       = module.workloads.ingress_hostname
}

output "external_dns_role_arn" {
  value = module.external_dns.role_arn
}
