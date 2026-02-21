#!/bin/bash

# ======================================
# Linux Bash Tools - System Baseline
# ======================================

STATUS=0

echo "======================================"
echo " Linux Bash Tools - System Baseline"
echo "======================================"
echo ""

# -------------------------------
# Kernel Information
# -------------------------------
echo "[*] Kernel Version"
uname -r
echo ""

# -------------------------------
# Operating System
# -------------------------------
echo "[*] Operating System"
grep PRETTY_NAME /etc/os-release 2>/dev/null
echo ""

# -------------------------------
# CPU Load
# -------------------------------
echo "[*] CPU Load"
LOAD_FULL=$(uptime | awk -F'load average:' '{ print $2 }')
echo "$LOAD_FULL"

LOAD_1MIN=$(echo "$LOAD_FULL" | cut -d, -f1 | tr -d ' ')

if command -v bc >/dev/null 2>&1; then
    if (( $(echo "$LOAD_1MIN > 4.0" | bc -l) )); then
        echo "[WARNING] High 1-minute load average detected: $LOAD_1MIN"
        STATUS=1
    fi
fi
echo ""

# -------------------------------
# Memory Usage
# -------------------------------
echo "[*] Memory Usage"
free -h
echo ""

# -------------------------------
# Disk Usage
# -------------------------------
echo "[*] Disk Usage"
df -h

DISK_ALERT=$(df -h | awk '$5+0 > 90 {print $0}')
if [ -n "$DISK_ALERT" ]; then
    echo ""
    echo "[WARNING] Disk usage above 90% detected:"
    echo "$DISK_ALERT"
    STATUS=1
fi
echo ""

# -------------------------------
# Top Processes
# -------------------------------
echo "[*] Top 5 Memory-Consuming Processes"
ps aux --sort=-%mem | head -n 6
echo ""

echo "[*] Top 5 CPU-Consuming Processes"
ps aux --sort=-%cpu | head -n 6
echo ""

# -------------------------------
# Listening Ports
# -------------------------------
echo "[*] Listening Ports"
ss -tuln
echo ""

# Only detect services bound to all interfaces
EXPOSED=$(ss -tuln | awk '
/LISTEN/ && ($5 ~ /^0\.0\.0\.0:/ || $5 ~ /^\*:/ || $5 ~ /^\[::\]:/ || $5 ~ /^:::/) {print}
')

if [ -n "$EXPOSED" ]; then
    echo "[WARNING] Services bound to all interfaces detected:"
    echo "$EXPOSED"
    STATUS=1
fi
echo ""

# -------------------------------
# Summary
# -------------------------------
echo "======================================"
echo " SUMMARY"
echo "======================================"

if [ "$STATUS" -eq 0 ]; then
    echo "Status: OK - No critical issues detected."
else
    echo "Status: WARNING - Review findings above."
fi

echo ""

exit $STATUS
