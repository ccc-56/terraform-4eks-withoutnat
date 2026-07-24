region       = "ap-southeast-1"
cluster_name = "url-shortener-eks"

namespace = "url-shortener"

app_repo_name = "urls/app"
image_tag     = "latest"

app_service_name = "shortname-app"
app_port         = 3000
app_replicas     = 2

redis_image = "redis:7-alpine"
redis_port  = 6379

nginx_image    = "nginx:alpine"
nginx_replicas = 2
