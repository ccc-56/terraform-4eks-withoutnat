# terraform-4eks-withoutnat

Terraform to deploy the [URL-shortern](https://github.com/ccc-56/URL-shortern) project on **Amazon EKS** with a deliberately cheap, **NAT-gateway-free** topology: the VPC has **only public subnets**, and every resource (EKS nodes and all workloads) lives in them.

- Region: `ap-southeast-1`
- VPC CIDR: `10.76.0.0/16`
- No NAT gateway (nodes get public IPs and route to the internet via the Internet Gateway)

## Architecture

```
Internet
   |
   v
ALB  (Ingress, internet-facing, public subnets, via AWS Load Balancer Controller)
   |
   v
nginx pods (ClusterIP)   static frontend + reverse proxy
   |  /api/, /r/
   v
app pods (shortname-app:3000)   Node.js + Express URL shortener
   |
   v
redis pod (redis:6379)          in-cluster Redis (plaintext)
```

Everything runs on an EKS managed node group placed in the two public subnets.
There is no NAT gateway, so the EKS control-plane endpoint is public and the
nodes reach ECR / the API over the Internet Gateway.

## Layout

```
terraform/
  modules/
    network/         public-only VPC: subnets, IGW, public route table (no NAT)
    eks/             EKS cluster, node group, IAM roles, add-ons, OIDC provider
    alb-controller/  AWS Load Balancer Controller (IRSA IAM role + Helm release)
    external-dns/    external-dns (IRSA IAM role + Helm release, AWS/Route53 provider)
    workloads/       Kubernetes: namespace, redis, app, nginx + ALB Ingress
  environments/
    production/
      01-infra/      network + EKS + ECR  (AWS provider)
      02-workloads/  ALB controller + external-dns + Kubernetes objects
                     (kubernetes/helm providers)
```

The two stacks are decoupled: `02-workloads` discovers the cluster and ECR repo
by name via data sources, so no shared remote state is required. Both stacks
use an **S3 backend** (`backend.tf`) — bucket `url-shortern-eks-tfstate` in
`ap-southeast-1`, created by the `00-backend` bootstrap stack (run first).

If a stack already has local state (e.g. it was applied before adding the S3
backend), migrate it after the bucket exists with:
`terraform init -migrate-state`.

## Prerequisites

- Terraform >= 1.5, AWS CLI, `kubectl`, and Docker
- AWS credentials for `ap-southeast-1` with permissions for VPC/EKS/IAM/ECR/ELB/Route53
- The same IAM identity should run both stacks (the cluster creator is granted
  Kubernetes admin automatically).

## Deploy

### 0. State backend bucket (run once)

The `01-infra` / `02-workloads` stacks store state in S3, so create the bucket
first. This bootstrap stack keeps its own state local.

```bash
cd terraform/environments/production/00-backend
terraform init
terraform apply
```

### 1. Infrastructure (VPC + EKS + ECR)

```bash
cd terraform/environments/production/01-infra
terraform init
terraform apply -var-file=terraform.tfvars
```

Note the outputs, then point kubectl at the cluster:

```bash
aws eks update-kubeconfig --region ap-southeast-1 --name url-shortener-eks
```

### 2. Build & push the app image to ECR

The `urls/app` ECR repo is created by stage 1. Build the app image from the
[URL-shortern](https://github.com/ccc-56/URL-shortern) repo and push it:

```bash
ECR_URL=$(terraform -chdir=terraform/environments/production/01-infra output -raw ecr_repository_url)
aws ecr get-login-password --region ap-southeast-1 \
  | docker login --username AWS --password-stdin "${ECR_URL%/*}"

git clone https://github.com/ccc-56/URL-shortern.git
cd URL-shortern
docker build -f Dockerfile-app -t "$ECR_URL:latest" .
docker push "$ECR_URL:latest"
```

The nginx tier uses the stock `nginx:alpine` image; the frontend and proxy
config are injected via ConfigMaps, so no custom nginx image is needed.

Stage 3 installs the AWS Load Balancer Controller (via Helm, with an IRSA role)
and creates an `alb`-class Ingress, so the public entrypoint is an internet-facing
**ALB** (not a Classic ELB). The controller uses `target-type: ip`, sending
traffic straight to the nginx pod IPs (works because the VPC CNI gives pods VPC IPs).

### 3. Workloads (redis + app + nginx)

```bash
cd terraform/environments/production/02-workloads
terraform init
terraform apply -var-file=terraform.tfvars
```

When the ALB is provisioned, open the app:

```bash
terraform output -raw load_balancer_hostname   # http://<hostname>/
```

### 4. DNS (external-dns)

Stage 3 also installs **external-dns**, which watches Ingresses/Services and
keeps Route53 in sync (`--policy=sync`, TXT registry owned by the cluster name).
Setting `ingress_hostname` creates a second, host-based Ingress
(`url-shortener-ing1`) with its own ALB; external-dns then publishes the
A/AAAA alias records for that hostname:

```hcl
# terraform/environments/production/02-workloads/terraform.tfvars
ingress_hostname            = "apin1.dongzh.store"
external_dns_domain_filters = ["dongzh.store"]   # limit external-dns to this zone
```

```bash
terraform output -raw ingress_hostname   # http://apin1.dongzh.store/
```

The Route53 hosted zone itself is not managed here — it must already exist in
the account. Leave `ingress_hostname` empty to skip the host-based Ingress.

## CI/CD (GitHub Actions)

- `.github/workflows/terraform-ci.yml` — on every PR touching `terraform/**`,
  runs `terraform fmt -check` + `validate` for all three stacks (no AWS creds).
- `.github/workflows/deploy.yml` — manual (**Actions → deploy → Run workflow**),
  with an `action` input (`plan` or `apply`). Runs the stages in order:
  `00-backend → 01-infra → build & push image → 02-workloads`.

Set these repo secrets first (Settings → Secrets and variables → Actions):

| Secret | Purpose |
| --- | --- |
| `AWS_ACCESS_KEY_ID` | IAM identity with VPC/EKS/IAM/ECR/ELB/S3/Route53 permissions |
| `AWS_SECRET_ACCESS_KEY` | matching secret key |

The deploy jobs use a `production` GitHub Environment, so you can add a required
reviewer there to gate `apply`. `plan` presumes the state bucket (and, for
`02-workloads`, the cluster) already exist — run `apply` for a first-time bootstrap.

## Notes / cost

- No NAT gateway is the main cost saving; the only always-on hourly costs are
  the EKS control plane, the node group EC2 instances, and one ALB.
- Public-subnet nodes are simpler and cheaper but less isolated than a
  private-subnet + NAT design. Lock down `public_access_cidrs` and the node
  security group for anything beyond a demo.
- Redis runs in-cluster without persistence; use ElastiCache for durability.

## Teardown

```bash
terraform -chdir=terraform/environments/production/02-workloads destroy -var-file=terraform.tfvars
terraform -chdir=terraform/environments/production/01-infra     destroy -var-file=terraform.tfvars
```
