region       = "ap-southeast-1"
cluster_name = "url-shortener-eks"

instance_type = "t3.micro"

# Narrow this to your own egress IP (e.g. ["1.2.3.4/32"]) for anything beyond a lab.
allowed_ssh_cidrs = ["0.0.0.0/0"]

tag_name     = "eks-nonat"
project_name = "url-shortener"
