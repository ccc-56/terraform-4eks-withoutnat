variable "vpc_name" {
  type = string
}

variable "vpc_cidr" {
  type = string
}

variable "azs" {
  type = list(string)
}

variable "public_subnet_cidrs" {
  type = list(string)
}

variable "cluster_name" {
  description = "EKS cluster name used to tag subnets for cluster/ELB discovery. Empty disables the tag."
  type        = string
  default     = ""
}

variable "tags" {
  type    = map(string)
  default = {}
}
