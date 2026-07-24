terraform {
  backend "s3" {
    bucket  = "url-shortern-eks-tfstate"
    key     = "eks-withoutnat/production/workloads.tfstate"
    region  = "ap-southeast-1"
    encrypt = true
  }
}
