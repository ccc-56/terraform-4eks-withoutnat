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

# Host-based Ingress; external-dns creates apin1.dongzh.store in Route53.
ingress_hostname            = "apin1.dongzh.store"
external_dns_domain_filters = ["dongzh.store"]
