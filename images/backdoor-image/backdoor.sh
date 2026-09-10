#!/bin/sh
# KOAD S12: Simulated backdoor — logs activity instead of actual malicious behavior
echo "[KOAD DEMO] Backdoor script executed at $(date)" >> /tmp/koad-backdoor.log
echo "[KOAD DEMO] In a real attack, this would establish a reverse shell" >> /tmp/koad-backdoor.log
echo "[KOAD DEMO] Hostname: $(hostname)" >> /tmp/koad-backdoor.log
echo "[KOAD DEMO] SA Token exists: $(test -f /var/run/secrets/kubernetes.io/serviceaccount/token && echo yes || echo no)" >> /tmp/koad-backdoor.log
