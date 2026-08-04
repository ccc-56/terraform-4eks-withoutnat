#!/usr/bin/env bash
# Remove the monitoring stack. Deleting the Ingresses first lets the AWS Load
# Balancer Controller reclaim the ALBs while it is still running — otherwise
# they are orphaned and block the VPC teardown later.
set -euo pipefail

RELEASE="${RELEASE:-monitoring}"
NAMESPACE="${NAMESPACE:-monitoring}"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

kubectl delete -f "$SCRIPT_DIR/ingresses.yaml" --ignore-not-found
helm uninstall "$RELEASE" --namespace "$NAMESPACE" --ignore-not-found
kubectl delete namespace "$NAMESPACE" --ignore-not-found
