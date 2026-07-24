variable "cluster_name" {
  type = string
}

variable "region" {
  type = string
}

variable "vpc_id" {
  type = string
}

variable "oidc_provider_arn" {
  type = string
}

variable "oidc_provider_url" {
  description = "OIDC issuer URL without the https:// scheme."
  type        = string
}

variable "service_account_name" {
  type    = string
  default = "aws-load-balancer-controller"
}

variable "namespace" {
  type    = string
  default = "kube-system"
}

variable "chart_version" {
  type    = string
  default = "1.7.2"
}

variable "tags" {
  type    = map(string)
  default = {}
}
