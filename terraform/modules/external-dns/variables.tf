variable "cluster_name" {
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
  default = "external-dns"
}

variable "namespace" {
  type    = string
  default = "kube-system"
}

variable "chart_version" {
  type    = string
  default = "1.21.1"
}

variable "sources" {
  description = "Kubernetes objects external-dns watches for hostnames."
  type        = list(string)
  default     = ["service", "ingress"]
}

variable "policy" {
  description = "sync also deletes records external-dns owns; upsert-only never deletes."
  type        = string
  default     = "sync"
}

variable "interval" {
  type    = string
  default = "1m"
}

variable "domain_filters" {
  description = "Restrict external-dns to these hosted zones; empty means all zones in the account."
  type        = list(string)
  default     = []
}

variable "tags" {
  type    = map(string)
  default = {}
}
