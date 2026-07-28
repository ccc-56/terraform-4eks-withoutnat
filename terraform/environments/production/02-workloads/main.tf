data "aws_ecr_repository" "app" {
  name = var.app_repo_name
}

# OIDC provider (created by 01-infra) used for the controller's IRSA role.
data "aws_iam_openid_connect_provider" "this" {
  url = data.aws_eks_cluster.this.identity[0].oidc[0].issuer
}

# AWS Load Balancer Controller: turns the Ingress below into an internet-facing ALB.
module "alb_controller" {
  source = "../../../modules/alb-controller"

  cluster_name      = var.cluster_name
  region            = var.region
  vpc_id            = data.aws_eks_cluster.this.vpc_config[0].vpc_id
  oidc_provider_arn = data.aws_iam_openid_connect_provider.this.arn
  oidc_provider_url = replace(data.aws_eks_cluster.this.identity[0].oidc[0].issuer, "https://", "")
}

# external-dns: publishes Route53 records for Ingress/Service hostnames.
module "external_dns" {
  source = "../../../modules/external-dns"

  cluster_name      = var.cluster_name
  oidc_provider_arn = data.aws_iam_openid_connect_provider.this.arn
  oidc_provider_url = replace(data.aws_eks_cluster.this.identity[0].oidc[0].issuer, "https://", "")
  domain_filters    = var.external_dns_domain_filters
}

module "workloads" {
  source = "../../../modules/workloads"

  namespace = var.namespace

  app_image        = "${data.aws_ecr_repository.app.repository_url}:${var.image_tag}"
  app_service_name = var.app_service_name
  app_port         = var.app_port
  app_replicas     = var.app_replicas

  redis_image = var.redis_image
  redis_port  = var.redis_port

  nginx_image    = var.nginx_image
  nginx_replicas = var.nginx_replicas

  ingress_hostname = var.ingress_hostname

  # The Ingress needs the controller running before an ALB can be provisioned.
  depends_on = [module.alb_controller]
}
