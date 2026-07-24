terraform {
  backend "s3" {
    bucket  = "url-shortern-eks-tfstate"
    key     = "eks-withoutnat/production/infra.tfstate"
    region  = "ap-southeast-1"
    encrypt = true
  }
}
