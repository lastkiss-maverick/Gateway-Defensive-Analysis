#!/bin/bash
# Security Audit Helper: Check Server Headers and Redirects
# Usage: ./recon_check.sh <IP>

TARGET=$1

if [ -z "$TARGET" ]; then
    echo "Usage: ./recon_check.sh <target-ip>"
    exit 1
fi

echo "[+] Analyzing Target: $TARGET"
echo "[+] Fetching HTTP Headers..."
curl -I -s http://$TARGET:8090/ | grep -E "Server|Location|HTTP"

echo "[+] Testing User-Agent Bypass..."
curl -I -s -A "Mozilla/5.0 (iPhone; CPU iPhone OS 17_0 like Mac OS X)" http://$TARGET:8090/ | grep "HTTP"
