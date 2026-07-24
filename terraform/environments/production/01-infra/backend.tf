# State is kept local by default so this stack applies without any pre-existing
# S3 bucket / DynamoDB table. To use a remote backend, uncomment and adjust:
#
# terraform {
#   backend "s3" {
#     bucket = "your-terraform-state-bucket"
#     key    = "eks-withoutnat/production/infra.tfstate"
#     region = "ap-southeast-1"
#   }
# }
