#!/bin/bash
set -euo pipefail

CYAN='\033[0;36m'
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m'

log() { echo -e "${GREEN}[KOAD]${NC} $1"; }
warn() { echo -e "${YELLOW}[WARN]${NC} $1"; }

BASE_DIR="$(cd "$(dirname "$0")" && pwd)"

log "Tearing down KOAD Lab..."

log "Removing scenario resources..."
for dir in "$BASE_DIR"/scenarios/*/; do
  if [ -d "$dir" ]; then
    for yaml in "$dir"*.yaml; do
      [ -f "$yaml" ] && kubectl delete -f "$yaml" --ignore-not-found 2>/dev/null || true
    done
  fi
done

log "Removing namespaces..."
for ns in koad koad-attack koad-defense koad-registry; do
  kubectl delete namespace "$ns" --ignore-not-found 2>/dev/null || true
done

log "Removing Falco..."
helm uninstall falco -n falco 2>/dev/null || true
kubectl delete namespace falco --ignore-not-found 2>/dev/null || true

log "Removing Kyverno..."
helm uninstall kyverno -n kyverno 2>/dev/null || true
kubectl delete namespace kyverno --ignore-not-found 2>/dev/null || true

log "KOAD Lab teardown complete."
echo ""
echo -e "  To also delete the Minikube cluster:"
echo -e "    ${YELLOW}minikube delete${NC}"
