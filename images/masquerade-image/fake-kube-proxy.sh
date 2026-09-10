#!/bin/sh
# KOAD S22: Simulated masquerade — logs instead of actual exfiltration
echo "[KOAD DEMO] Fake kube-proxy started at $(date)"
echo "[KOAD DEMO] This masquerades as a system component"
echo "[KOAD DEMO] In a real attack, this would exfiltrate cluster data"

while true; do
  echo "[KOAD DEMO] Heartbeat — $(date)"
  sleep 300
done
