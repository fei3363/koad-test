#!/bin/sh
# KOAD S35: Simulated cryptominer — generates CPU activity without actual mining
echo "[KOAD DEMO] Simulated XMRig miner started"
echo "[KOAD DEMO] Pool: stratum+tcp://pool.example.com:3333"
echo "[KOAD DEMO] Wallet: 4FAKE_WALLET_ADDRESS"

while true; do
  echo "[KOAD DEMO] [$(date)] hashrate: 0.00 H/s (simulated)"
  sleep 60
done
