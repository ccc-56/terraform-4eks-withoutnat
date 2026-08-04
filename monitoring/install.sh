#!/usr/bin/env bash
# Install kube-prometheus-stack (Prometheus + Alertmanager + Grafana + exporters)
# on the url-shortener EKS cluster, plus the host-based ALB Ingresses.
#
#   ./monitoring/install.sh
#
# Requires: kubectl pointed at the cluster, helm, and the AWS Load Balancer
# Controller + external-dns already installed (02-workloads stack).
set -euo pipefail

CHART_VERSION="${CHART_VERSION:-88.1.3}"
RELEASE="${RELEASE:-monitoring}"
NAMESPACE="${NAMESPACE:-monitoring}"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
helm repo update prometheus-community

helm upgrade --install "$RELEASE" prometheus-community/kube-prometheus-stack \
  --namespace "$NAMESPACE" \
  --create-namespace \
  --version "$CHART_VERSION" \
  --values "$SCRIPT_DIR/values.yaml" \
  --wait --timeout 15m

kubectl apply -f "$SCRIPT_DIR/ingresses.yaml"

echo
echo "Waiting for the ALBs to be provisioned..."
kubectl wait --namespace "$NAMESPACE" --for=jsonpath='{.status.loadBalancer.ingress[0].hostname}' \
  --timeout=5m ingress/grafana-ing1 ingress/prom-ing1 ingress/node-ing1 ingress/pod-ing1

kubectl get ingress -n "$NAMESPACE"
echo
echo "Grafana admin password:"
echo "  kubectl get secret -n $NAMESPACE $RELEASE-grafana -o jsonpath='{.data.admin-password}' | base64 -d"
