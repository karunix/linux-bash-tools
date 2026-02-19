#!/bin/bash

# Firewall Exposure Audit
# Version 2 - Refined TCP Exposure Detection

WARNINGS=0

echo "===== Firewall Exposure Audit ====="
echo

# ----------------------------------------
# 1. Firewall Status
# ----------------------------------------

echo "== Firewall Status =="

if systemctl is-active --quiet firewalld; then
    echo "firewalld: ACTIVE"
else
    echo "firewalld: INACTIVE"
    echo "WARNING: Firewall service is not running."
    WARNINGS=$((WARNINGS + 1))
fi

echo

# ----------------------------------------
# 2. Listening TCP Ports Only
# ----------------------------------------

echo "== Listening TCP Ports (ss -tlnp) =="

ss -tlnp

echo

# ----------------------------------------
# 3. TCP Services Bound to All Interfaces
# ----------------------------------------

echo "== TCP Services Bound to All Interfaces (0.0.0.0 / ::) =="

# Capture only TCP LISTEN entries bound to all interfaces
EXPOSED=$(ss -tlnp | awk '
NR>1 {
    local_address=$4
    if (local_address ~ /^0\.0\.0\.0:/ || local_address ~ /^\[::\]:/) {
        print
    }
}')

if [ -n "$EXPOSED" ]; then
    echo "$EXPOSED"
    echo
    echo "WARNING: TCP service(s) listening on all interfaces detected."
    WARNINGS=$((WARNINGS + 1))
else
    echo "No TCP services bound to all interfaces detected."
fi

echo

# ----------------------------------------
# 4. Firewall Rules Overview
# ----------------------------------------

echo "== Active Firewall Configuration =="

if systemctl is-active --quiet firewalld; then
    firewall-cmd --list-all
else
    echo "Firewall not active. Skipping rule listing."
fi

echo

# ----------------------------------------
# Summary
# ----------------------------------------

echo "===== Audit Summary ====="

if [ "$WARNINGS" -eq 0 ]; then
    echo "STATUS: PASS - No high-risk TCP exposure detected."
    exit 0
else
    echo "STATUS: WARNING - $WARNINGS potential TCP exposure issue(s) detected."
    exit 1
fi
