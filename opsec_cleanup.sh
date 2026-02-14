#!/bin/zsh
# OPSEC Cleanup: Clear session history and flush DNS
# Designed for Kali Linux (Zsh) and macOS

echo "[*] Clearing Zsh History..."
echo > ~/.zsh_history
fc -p

echo "[*] Flushing Host DNS Cache..."
if [[ "$OSTYPE" == "darwin"* ]]; then
    sudo dscacheutil -flushcache; sudo killall -HUP mDNSResponder
    echo "[+] macOS DNS Flushed."
fi

echo "[*] Resetting Network Interface..."
sudo ifconfig eth0 down
sudo macchanger -p eth0
sudo ifconfig eth0 up

echo "[!] Audit Session Terminated Cleanly."
