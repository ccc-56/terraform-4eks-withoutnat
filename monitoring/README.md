# Monitoring stack (Prometheus + Grafana)

`kube-prometheus-stack` on the `url-shortener-eks` cluster, exposed through four
host-based ALB Ingresses. external-dns publishes the Route53 records, so the
endpoints come up on their own once the Ingresses are created.

| Host | Backend | Port |
| --- | --- | --- |
| `grafana1.dongzh.store` | `monitoring-grafana` | 80 |
| `prom1.dongzh.store` | `monitoring-kube-prometheus-prometheus` | 9090 |
| `node1.dongzh.store` | `monitoring-prometheus-node-exporter` | 9100 |
| `pod1.dongzh.store` | `monitoring-kube-state-metrics` | 8080 |

## Install

```bash
aws eks update-kubeconfig --region ap-southeast-1 --name url-shortener-eks
./monitoring/install.sh
```

Chart version is pinned in `install.sh` (`CHART_VERSION`, currently 88.1.3);
`values.yaml` holds the Helm values.

Grafana admin password:

```bash
kubectl get secret -n monitoring monitoring-grafana \
  -o jsonpath='{.data.admin-password}' | base64 -d
```

## Uninstall

```bash
./monitoring/uninstall.sh
```

Always run this (or delete the Ingresses by hand) **before** destroying
`01-infra`. The ALBs are created by the in-cluster controller, not by
Terraform, so tearing down the cluster first leaves them orphaned and blocks
the VPC deletion.

## Rebuild from nothing

```bash
terraform -chdir=terraform/environments/production/00-backend apply
terraform -chdir=terraform/environments/production/01-infra   apply -var-file=terraform.tfvars
# build & push the app image (see the root README), then:
terraform -chdir=terraform/environments/production/02-workloads apply -var-file=terraform.tfvars
aws eks update-kubeconfig --region ap-southeast-1 --name url-shortener-eks
./monitoring/install.sh
```

## Pausing instead of destroying

To stop paying for the nodes overnight while keeping the cluster and all of its
objects, scale the node group to zero and delete the Ingresses (each ALB is
billed hourly even with no traffic):

```bash
kubectl delete -f monitoring/ingresses.yaml
kubectl delete ingress -n url-shortener url-shortener url-shortener-ing1
aws eks update-nodegroup-config --region ap-southeast-1 \
  --cluster-name url-shortener-eks --nodegroup-name url-shortener-eks-ng \
  --scaling-config minSize=0,desiredSize=0,maxSize=3
```

Resume with `--scaling-config minSize=1,desiredSize=2,maxSize=3`, then re-apply
the Ingresses. Note that a later `terraform apply` resets the scaling config to
the values in `terraform.tfvars`.

Prometheus and Grafana run without persistent volumes, so metric history does
not survive a pod restart either way — see the commented `storageSpec` block in
`values.yaml` to change that.
