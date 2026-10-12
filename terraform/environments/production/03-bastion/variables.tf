variable "region" {
  description = "AWS region of the EKS cluster."
  type        = string
}

variable "cluster_name" {
  description = "Name of the EKS cluster (created by 01-infra) the bastion administers."
  type        = string
}

variable "name" {
  description = "Name prefix for the bastion resources."
  type        = string
  default     = "eks-bastion"
}

variable "instance_type" {
  description = "EC2 instance type of the bastion."
  type        = string
  default     = "t3.micro"
}

variable "ssh_public_key" {
  description = "OpenSSH public key allowed to log in as the ubuntu user (pass via TF_VAR_ssh_public_key)."
  type        = string
}

variable "allowed_ssh_cidrs" {
  description = "CIDRs allowed to reach the bastion on 22/tcp."
  type        = list(string)
  default     = ["0.0.0.0/0"]
}

variable "tag_name" {
  description = "Environment tag value."
  type        = string
}

variable "project_name" {
  description = "Project tag value."
  type        = string
}
