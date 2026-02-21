#!/bin/bash

# ======================================
# Linux Bash Tools - Network Baseline Audit
# ======================================

warning_count=0

echo "======================================"
echo " Linux Bash Tools - Network Baseline"
echo "======================================"

########################################
# 1. IP & Interface Status
########################################
echo
echo "== IP & Interface Status =="

ip -brief addr show 2>/dev/null

active_ifaces=$(ip -brief link show up 2>/dev/null | grep -v LOOPBACK | wc -l)

if [ "$active_ifaces" -eq 0 ]; then
    echo "WARNING: No active network interfaces detected."
    warning_count=$((warning_count+1))
fi

########################################
# 2. Routing & Gateway
########################################
echo
echo "== Routing Table =="

ip route show 2>/dev/null

default_route=$(ip route | grep "^default" | head -n1)

if [ -z "$default_route" ]; then
    echo "WARNING: No default gateway configured."
    warning_count=$((warning_count+1))
else
    gateway=$(echo "$default_route" | awk '{print $3}')
    interface=$(echo "$default_route" | awk '{print $5}')

    echo
    echo "Default Gateway: $gateway"
    echo "Interface Used:  $interface"

    # Check if interface is UP
    ip link show "$interface" | grep -q "state UP"
    if [ $? -ne 0 ]; then
        echo "WARNING: Default route interface is DOWN."
        warning_count=$((warning_count+1))
    fi

    # Attempt reachability test
    ping -c1 -W1 "$gateway" >/dev/null 2>&1
    if [ $? -ne 0 ]; then
        echo "WARNING: Gateway did not respond to ICMP (may be blocked)."
        warning_count=$((warning_count+1))
    fi
fi

########################################
# 3. DNS Resolution
########################################
echo
echo "== DNS Configuration =="

if [ -f /etc/resolv.conf ]; then
    grep nameserver /etc/resolv.conf
else
    echo "WARNING: /etc/resolv.conf not found."
    warning_count=$((warning_count+1))
fi

getent hosts google.com >/dev/null 2>&1
if [ $? -ne 0 ]; then
    echo "WARNING: DNS resolution failed."
    warning_count=$((warning_count+1))
fi

########################################
# 4. Reverse Path Filtering (rp_filter)
########################################
echo
echo "== Reverse Path Filtering (rp_filter) =="

rp_filter=$(sysctl -n net.ipv4.conf.all.rp_filter 2>/dev/null)

if [[ "$rp_filter" =~ ^[0-9]+$ ]]; then
    echo "rp_filter value: $rp_filter"
    if [ "$rp_filter" -eq 0 ]; then
        echo "WARNING: rp_filter is disabled."
        warning_count=$((warning_count+1))
    fi
else
    echo "WARNING: Unable to determine rp_filter value."
    warning_count=$((warning_count+1))
fi

########################################
# 5. Listening TCP Services
########################################
echo
echo "== Listening TCP Services =="

ss -tln 2>/dev/null

tcp_count=$(ss -tln 2>/dev/null | awk '/LISTEN/ {count++} END {print count+0}')

echo
echo "Listening TCP sockets: $tcp_count"

if [ "$tcp_count" -gt 10 ]; then
    echo "WARNING: High number of listening TCP services."
    warning_count=$((warning_count+1))
fi

########################################
# 6. Public Bind Detection
########################################
echo
echo "== Public Bind Detection =="

public_binds=$(ss -tln 2>/dev/null | awk '
/LISTEN/ && ($4 ~ /^0\.0\.0\.0:/ || $4 ~ /^\*:/ || $4 ~ /^\[::\]:/ || $4 ~ /^:::/) {print}
')

if [ -n "$public_binds" ]; then
    echo "WARNING: Services bound to all interfaces:"
    echo "$public_binds"
    warning_count=$((warning_count+1))
else
    echo "No publicly bound TCP services detected."
fi

########################################
# Summary
########################################
echo
echo "======================================"
echo " Audit Summary"
echo "======================================"

if [ "$warning_count" -gt 0 ]; then
    echo "STATUS: WARNING - Network hardening improvements recommended."
    exit 1
else
    echo "STATUS: PASS - Network baseline normal."
    exit 0
fi
