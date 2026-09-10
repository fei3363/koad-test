#!/bin/bash
set -euo pipefail

GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

log() { echo -e "${GREEN}[KOAD]${NC} $1"; }

log "Running CIS Kubernetes Benchmark..."
kubectl delete job kube-bench -n koad-defense --ignore-not-found 2>/dev/null
kubectl apply -f "$(dirname "$0")/job.yaml"

log "Waiting for benchmark to complete..."
kubectl wait --for=condition=complete job/kube-bench -n koad-defense --timeout=120s 2>/dev/null || true

echo ""
echo -e "${YELLOW}=== Benchmark Results ===${NC}"
kubectl logs job/kube-bench -n koad-defense 2>/dev/null || echo "Job not ready yet — check with: kubectl logs job/kube-bench -n koad-defense"
