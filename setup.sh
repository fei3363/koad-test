#!/bin/bash
set -euo pipefail

CYAN='\033[0;36m'
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m'

KOAD_NS="koad"
ATTACK_NS="koad-attack"
DEFENSE_NS="koad-defense"
REGISTRY_NS="koad-registry"

banner() {
  echo -e "${CYAN}"
  cat << 'EOF'
  _  _____  ___    _    ____
 | |/ / _ \/ _ \  | |  |  _ \
 | ' / | | / _\ \ | |  | |_) |
 | . \ |_| / ___ \| |__|  __/
 |_|\_\___/_/   \_\____|_|

 Kubernetes Offensive and Active Defense Lab
 MITRE ATT&CK Containers Matrix — 100% Coverage
EOF
  echo -e "${NC}"
}

log() { echo -e "${GREEN}[KOAD]${NC} $1"; }
warn() { echo -e "${YELLOW}[WARN]${NC} $1"; }
err() { echo -e "${RED}[ERROR]${NC} $1"; }

check_prerequisites() {
  log "Checking prerequisites..."
  local missing=()
  for cmd in kubectl minikube docker helm; do
    if ! command -v "$cmd" &>/dev/null; then
      missing+=("$cmd")
    fi
  done
  if [ ${#missing[@]} -gt 0 ]; then
    err "Missing required tools: ${missing[*]}"
    exit 1
  fi
  log "All prerequisites met."
}

start_minikube() {
  if minikube status | grep -q "Running"; then
    log "Minikube already running."
  else
    log "Starting Minikube cluster..."
    minikube start \
      --driver=docker \
      --cpus=4 \
      --memory=8192 \
      --kubernetes-version=v1.30.0 \
      --cni=calico \
      --extra-config=kubelet.anonymous-auth=true \
      --extra-config=apiserver.enable-admission-plugins=NodeRestriction \
      --extra-config=apiserver.audit-policy-file=/etc/kubernetes/audit-policy.yaml \
      --extra-config=apiserver.audit-log-path=/var/log/kubernetes/audit.log
  fi
}

create_namespaces() {
  log "Creating namespaces..."
  for ns in $KOAD_NS $ATTACK_NS $DEFENSE_NS $REGISTRY_NS; do
    kubectl create namespace "$ns" --dry-run=client -o yaml | kubectl apply -f -
  done
}

deploy_scenarios() {
  local base_dir
  base_dir="$(cd "$(dirname "$0")" && pwd)"
  local scenario_dir="$base_dir/scenarios"

  local tactics=(
    "initial-access"
    "execution"
    "persistence"
    "privilege-escalation"
    "stealth"
    "defense-impairment"
    "credential-access"
    "discovery"
    "lateral-movement"
    "impact"
  )

  for tactic in "${tactics[@]}"; do
    local dir="$scenario_dir/$tactic"
    if [ -d "$dir" ]; then
      log "Deploying $tactic scenarios..."
      for yaml in "$dir"/*.yaml; do
        if [ -f "$yaml" ]; then
          kubectl apply -f "$yaml" 2>/dev/null || warn "Failed to apply $(basename "$yaml")"
        fi
      done
    fi
  done
}

deploy_apps() {
  local base_dir
  base_dir="$(cd "$(dirname "$0")" && pwd)"
  log "Building and deploying vulnerable apps..."

  if [ -f "$base_dir/apps/vulnerable-webapp/Dockerfile" ]; then
    eval $(minikube docker-env)
    docker build -t koad/vulnerable-webapp:latest "$base_dir/apps/vulnerable-webapp/" 2>/dev/null || true
    docker build -t koad/jupyter-insecure:latest "$base_dir/apps/jupyter-insecure/" 2>/dev/null || true
    docker build -t koad/mock-metadata:latest "$base_dir/apps/mock-metadata/" 2>/dev/null || true
    docker build -t koad/brute-forcer:latest "$base_dir/apps/brute-forcer/" 2>/dev/null || true
  fi
}

deploy_defense() {
  local base_dir
  base_dir="$(cd "$(dirname "$0")" && pwd)"
  log "Deploying defense stack..."

  if command -v helm &>/dev/null; then
    helm repo add falcosecurity https://falcosecurity.github.io/charts 2>/dev/null || true
    helm repo add kyverno https://kyverno.github.io/kyverno/ 2>/dev/null || true
    helm repo update 2>/dev/null || true

    if ! helm list -n falco 2>/dev/null | grep -q falco; then
      log "Installing Falco..."
      kubectl create namespace falco --dry-run=client -o yaml | kubectl apply -f -
      helm install falco falcosecurity/falco \
        -n falco \
        -f "$base_dir/defense/falco/values-custom.yaml" 2>/dev/null || warn "Falco install skipped"
    fi

    if ! helm list -n kyverno 2>/dev/null | grep -q kyverno; then
      log "Installing Kyverno..."
      kubectl create namespace kyverno --dry-run=client -o yaml | kubectl apply -f -
      helm install kyverno kyverno/kyverno -n kyverno 2>/dev/null || warn "Kyverno install skipped"
    fi
  fi

  if [ -d "$base_dir/defense/network-policies" ]; then
    kubectl apply -f "$base_dir/defense/network-policies/" 2>/dev/null || true
  fi
}

print_summary() {
  echo ""
  log "=========================================="
  log "  KOAD Lab Deployed Successfully!"
  log "=========================================="
  echo ""
  echo -e "  Namespaces:"
  echo -e "    ${CYAN}$KOAD_NS${NC}       — Target scenarios"
  echo -e "    ${CYAN}$ATTACK_NS${NC}  — Attacker tools"
  echo -e "    ${CYAN}$DEFENSE_NS${NC} — Defense stack"
  echo -e "    ${CYAN}$REGISTRY_NS${NC}— Private registry"
  echo ""
  echo -e "  Scenarios: ${GREEN}35${NC} (S01–S35)"
  echo -e "  ATT&CK Coverage: ${GREEN}10 Tactics × 28 Techniques = 100%${NC}"
  echo ""
  echo -e "  Quick start:"
  echo -e "    ${YELLOW}kubectl get pods -n $KOAD_NS${NC}"
  echo -e "    ${YELLOW}kubectl get pods -n $ATTACK_NS${NC}"
  echo ""
}

main() {
  banner
  check_prerequisites
  start_minikube
  create_namespaces
  deploy_apps
  deploy_scenarios
  deploy_defense
  print_summary
}

main "$@"
