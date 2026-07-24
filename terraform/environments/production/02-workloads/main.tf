data "aws_ecr_repository" "app" {
  name = var.app_repo_name
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
}
