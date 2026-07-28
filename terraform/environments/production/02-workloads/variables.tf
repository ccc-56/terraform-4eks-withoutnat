variable "region" {
  type    = string
  default = "ap-southeast-1"
}

variable "cluster_name" {
  type    = string
  default = "url-shortener-eks"
}

variable "namespace" {
  type    = string
  default = "url-shortener"
}

variable "app_repo_name" {
  type    = string
  default = "urls/app"
}

variable "image_tag" {
  type    = string
  default = "latest"
}

variable "app_service_name" {
  type    = string
  default = "shortname-app"
}

variable "app_port" {
  type    = number
  default = 3000
}

variable "app_replicas" {
  type    = number
  default = 2
}

variable "redis_image" {
  type    = string
  default = "redis:7-alpine"
}

variable "redis_port" {
  type    = number
  default = 6379
}

variable "nginx_image" {
  type    = string
  default = "nginx:alpine"
}

variable "nginx_replicas" {
  type    = number
  default = 2
}

variable "ingress_hostname" {
  description = "DNS name for the host-based Ingress; external-dns publishes it to Route53. Empty disables that Ingress."
  type        = string
  default     = ""
}

variable "external_dns_domain_filters" {
  description = "Restrict external-dns to these hosted zones; empty means all zones in the account."
  type        = list(string)
  default     = []
}
