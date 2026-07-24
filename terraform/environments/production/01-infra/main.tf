locals {
  common_tags = {
    Environment = var.tag_name
    Project     = var.project_name
  }
}

module "network" {
  source = "../../../modules/network"

  vpc_name            = var.vpc_name
  vpc_cidr            = var.vpc_cidr
  azs                 = var.azs
  public_subnet_cidrs = var.public_subnet_cidrs
  cluster_name        = var.cluster_name

  tags = local.common_tags
}

module "eks" {
  source = "../../../modules/eks"

  cluster_name        = var.cluster_name
  cluster_version     = var.cluster_version
  public_subnet_ids   = module.network.public_subnet_ids
  public_access_cidrs = var.public_access_cidrs

  node_instance_types = var.node_instance_types
  node_desired_size   = var.node_desired_size
  node_min_size       = var.node_min_size
  node_max_size       = var.node_max_size

  tags = local.common_tags
}

# Container registry for the URL shortener app image.
resource "aws_ecr_repository" "app" {
  name                 = var.app_repo_name
  image_tag_mutability = "MUTABLE"
  force_delete         = true

  image_scanning_configuration {
    scan_on_push = true
  }

  tags = local.common_tags
}
