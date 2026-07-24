region = "ap-southeast-1"

vpc_name = "eks-nonat-vpc"

vpc_cidr = "10.74.0.0/16"

azs = [
  "ap-southeast-1a",
  "ap-southeast-1b",
]

# Public subnets only: every workload and the EKS nodes live here (no NAT gateway).
public_subnet_cidrs = [
  "10.74.10.0/24",
  "10.74.20.0/24",
]

tag_name = "eks-nonat"

project_name = "url-shortener"

cluster_name = "url-shortener-eks"

cluster_version = "1.30"

node_instance_types = ["t3.small"]
node_desired_size   = 2
node_min_size       = 1
node_max_size       = 3

app_repo_name = "urls/app"
