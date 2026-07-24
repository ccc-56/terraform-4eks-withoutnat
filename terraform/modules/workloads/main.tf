terraform {
  required_providers {
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = ">= 2.30"
    }
  }
}

locals {
  redis_service_name = "redis"
  redis_addr         = "${local.redis_service_name}:${var.redis_port}"
}

resource "kubernetes_namespace_v1" "this" {
  metadata {
    name = var.namespace
  }
}

# --- Redis (in-cluster, plaintext) -----------------------------------------
resource "kubernetes_deployment_v1" "redis" {
  metadata {
    name      = local.redis_service_name
    namespace = kubernetes_namespace_v1.this.metadata[0].name
    labels    = { app = local.redis_service_name }
  }

  spec {
    replicas = 1

    selector {
      match_labels = { app = local.redis_service_name }
    }

    template {
      metadata {
        labels = { app = local.redis_service_name }
      }

      spec {
        container {
          name  = "redis"
          image = var.redis_image

          port {
            container_port = var.redis_port
          }

          resources {
            requests = {
              cpu    = "50m"
              memory = "64Mi"
            }
            limits = {
              cpu    = "250m"
              memory = "256Mi"
            }
          }
        }
      }
    }
  }
}

resource "kubernetes_service_v1" "redis" {
  metadata {
    name      = local.redis_service_name
    namespace = kubernetes_namespace_v1.this.metadata[0].name
  }

  spec {
    selector = { app = local.redis_service_name }

    port {
      port        = var.redis_port
      target_port = var.redis_port
    }

    type = "ClusterIP"
  }
}

# --- URL shortener app ------------------------------------------------------
resource "kubernetes_deployment_v1" "app" {
  metadata {
    name      = var.app_service_name
    namespace = kubernetes_namespace_v1.this.metadata[0].name
    labels    = { app = var.app_service_name }
  }

  spec {
    replicas = var.app_replicas

    selector {
      match_labels = { app = var.app_service_name }
    }

    template {
      metadata {
        labels = { app = var.app_service_name }
      }

      spec {
        container {
          name  = "app"
          image = var.app_image

          port {
            container_port = var.app_port
          }

          env {
            name  = "PORT"
            value = tostring(var.app_port)
          }

          # Force plaintext redis:// so the app does not attempt TLS (rediss://).
          env {
            name  = "REDIS_URL"
            value = "redis://${local.redis_addr}"
          }

          env {
            name  = "REDIS_HOST"
            value = local.redis_service_name
          }

          env {
            name  = "REDIS_PORT"
            value = tostring(var.redis_port)
          }

          resources {
            requests = {
              cpu    = "50m"
              memory = "64Mi"
            }
            limits = {
              cpu    = "500m"
              memory = "256Mi"
            }
          }
        }
      }
    }
  }

  depends_on = [kubernetes_service_v1.redis]
}

resource "kubernetes_service_v1" "app" {
  metadata {
    name      = var.app_service_name
    namespace = kubernetes_namespace_v1.this.metadata[0].name
  }

  spec {
    selector = { app = var.app_service_name }

    port {
      port        = var.app_port
      target_port = var.app_port
    }

    type = "ClusterIP"
  }
}

# --- Public nginx (static frontend + reverse proxy) -------------------------
resource "kubernetes_config_map_v1" "nginx" {
  metadata {
    name      = "nginx-config"
    namespace = kubernetes_namespace_v1.this.metadata[0].name
  }

  data = {
    "default.conf" = templatefile("${path.module}/files/default.conf", {
      app_service_name = var.app_service_name
      app_port         = var.app_port
    })
  }
}

resource "kubernetes_config_map_v1" "frontend" {
  metadata {
    name      = "nginx-frontend"
    namespace = kubernetes_namespace_v1.this.metadata[0].name
  }

  data = {
    "index.html" = file("${path.module}/files/index.html")
    "script.js"  = file("${path.module}/files/script.js")
  }
}

resource "kubernetes_deployment_v1" "nginx" {
  metadata {
    name      = "nginx"
    namespace = kubernetes_namespace_v1.this.metadata[0].name
    labels    = { app = "nginx" }
  }

  spec {
    replicas = var.nginx_replicas

    selector {
      match_labels = { app = "nginx" }
    }

    template {
      metadata {
        labels = { app = "nginx" }
      }

      spec {
        container {
          name  = "nginx"
          image = var.nginx_image

          port {
            container_port = 80
          }

          volume_mount {
            name       = "nginx-config"
            mount_path = "/etc/nginx/conf.d"
          }

          volume_mount {
            name       = "nginx-frontend"
            mount_path = "/usr/share/nginx/html"
          }

          resources {
            requests = {
              cpu    = "25m"
              memory = "32Mi"
            }
            limits = {
              cpu    = "250m"
              memory = "128Mi"
            }
          }
        }

        volume {
          name = "nginx-config"
          config_map {
            name = kubernetes_config_map_v1.nginx.metadata[0].name
          }
        }

        volume {
          name = "nginx-frontend"
          config_map {
            name = kubernetes_config_map_v1.frontend.metadata[0].name
          }
        }
      }
    }
  }

  # nginx resolves the app Service name at startup, so make sure it exists first.
  depends_on = [kubernetes_service_v1.app]
}

resource "kubernetes_service_v1" "nginx" {
  metadata {
    name      = "nginx"
    namespace = kubernetes_namespace_v1.this.metadata[0].name
    # No annotations: the in-tree AWS cloud provider provisions an
    # internet-facing Classic ELB in the tagged public subnets, so no extra
    # AWS Load Balancer Controller install is required.
  }

  spec {
    selector = { app = "nginx" }

    port {
      port        = 80
      target_port = 80
    }

    type = "LoadBalancer"
  }
}
