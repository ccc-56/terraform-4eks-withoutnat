output "namespace" {
  value = kubernetes_namespace_v1.this.metadata[0].name
}

output "load_balancer_hostname" {
  description = "Public ALB hostname from the Ingress. Point your CNAME here."
  value       = try(kubernetes_ingress_v1.this.status[0].load_balancer[0].ingress[0].hostname, "")
}

output "hostname_load_balancer_hostname" {
  description = "ALB hostname of the host-based Ingress (empty when ingress_hostname is unset)."
  value       = try(kubernetes_ingress_v1.hostname[0].status[0].load_balancer[0].ingress[0].hostname, "")
}

output "ingress_hostname" {
  description = "DNS name external-dns publishes for the host-based Ingress."
  value       = var.ingress_hostname
}
