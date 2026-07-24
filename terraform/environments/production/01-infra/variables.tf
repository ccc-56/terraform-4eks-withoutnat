variable "region" {
  type    = string
  default = "ap-southeast-1"
}

variable "vpc_name" {
  type    = string
  default = "eks-nonat-vpc"
}

variable "vpc_cidr" {
  type    = string
  default = "10.74.0.0/16"
}

variable "azs" {
  type = list(string)
}

variable "public_subnet_cidrs" {
  type = list(string)
}

variable "tag_name" {
  type    = string
  default = "eks-nonat"
}

variable "project_name" {
  type    = string
  default = "url-shortener"
}

variable "cluster_name" {
  type    = string
  default = "url-shortener-eks"
}

variable "cluster_version" {
  type    = string
  default = "1.30"
}

variable "public_access_cidrs" {
  type    = list(string)
  default = ["0.0.0.0/0"]
}

variable "node_instance_types" {
  type    = list(string)
  default = ["t3.small"]
}

variable "node_desired_size" {
  type    = number
  default = 2
}

variable "node_min_size" {
  type    = number
  default = 1
}

variable "node_max_size" {
  type    = number
  default = 3
}

variable "app_repo_name" {
  type    = string
  default = "urls/app"
}
