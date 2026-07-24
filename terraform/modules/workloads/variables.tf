variable "namespace" {
  type    = string
  default = "url-shortener"
}

variable "app_image" {
  description = "Full URL shortener app image reference, e.g. <account>.dkr.ecr.<region>.amazonaws.com/urls/app:latest"
  type        = string
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
