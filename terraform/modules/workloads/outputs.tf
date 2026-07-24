output "namespace" {
  value = kubernetes_namespace_v1.this.metadata[0].name
}

output "load_balancer_hostname" {
  description = "Public hostname of the nginx LoadBalancer. Point your CNAME here."
  value       = try(kubernetes_service_v1.nginx.status[0].load_balancer[0].ingress[0].hostname, "")
}
