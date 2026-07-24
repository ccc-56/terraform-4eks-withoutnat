output "namespace" {
  value = kubernetes_namespace_v1.this.metadata[0].name
}

output "load_balancer_hostname" {
  description = "Public ALB hostname from the Ingress. Point your CNAME here."
  value       = try(kubernetes_ingress_v1.this.status[0].load_balancer[0].ingress[0].hostname, "")
}
