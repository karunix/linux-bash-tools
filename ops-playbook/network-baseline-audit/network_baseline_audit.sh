#!/bin/bash

warning_count=0

echo "===== Network Baseline Audit ====="
echo

########################################
# 1. Interfaces & IP Addressing
########################################
echo "== Network Interfaces & IP Addresses =="

ip -4 addr show | grep inet
echo

# Exclude private, loopback, and link-local ranges
public_ips=$(ip -4 addr show | awk '/inet / {print $2}' | cut -d/ -f1 | \
grep -Ev '^(127\.|10\.|192\.168\.|169\.254\.|172\.(1[6-9]|2[0-9]|3[0-1])\.)')

if [ -n "$public_ips" ]; then
    echo "WARNING: Public IPv4 address detected:"
    echo "$public_ips"
    warning_count=$((warning_count+1))
else
    echo "No public IPv4 addresses detected."
fi

########################################
# 2. Default Gateway & Routing
########################################
echo
echo "== Routing Table =="

default_routes=$(ip route | grep '^default')
echo "$default_routes"

route_count=$(echo "$default_routes" | wc -l)

if [ "$route_count" -eq 0 ]; then
    echo "WARNING: No default route configured."
    warning_count=$((warning_count+1))
elif [ "$route_count" -gt 1 ]; then
    echo "WARNING: Multiple default routes detected."
    warning_count=$((warning_count+1))
fi

########################################
# 3. DNS Configuration
########################################
echo
echo "== DNS Configuration (/etc/resolv.conf) =="

if [ -f /etc/resolv.conf ]; then
    nameservers=$(grep '^nameserver' /etc/resolv.conf)
    echo "$nameservers"

    ns_count=$(echo "$nameservers" | wc -l)

    if [ "$ns_count" -eq 0 ]; then
        echo "WARNING: No nameservers configured."
        warning_count=$((warning_count+1))
    elif [ "$ns_count" -gt 3 ]; then
        echo "WARNING: More than 3 nameservers configured."
        warning_count=$((warning_count+1))
    fi
else
    echo "WARNING: /etc/resolv.conf not found."
    warning_count=$((warning_count+1))
fi

########################################
# 4. IP Forwarding
########################################
echo
echo "== IP Forwarding =="

ipv4_forward=$(sysctl -n net.ipv4.ip_forward 2>/dev/null)
ipv6_forward=$(sysctl -n net.ipv6.conf.all.forwarding 2>/dev/null)

echo "IPv4 Forwarding: $ipv4_forward"
echo "IPv6 Forwarding: $ipv6_forward"

if [ "$ipv4_forward" -eq 1 ] || [ "$ipv6_forward" -eq 1 ]; then
    echo "WARNING: IP forwarding is enabled."
    warning_count=$((warning_count+1))
fi

########################################
# 5. Reverse Path Filtering
########################################
echo
echo "== Reverse Path Filtering =="

rp_filter=$(sysctl -n net.ipv4.conf.all.rp_filter 2>/dev/null)
echo "rp_filter: $rp_filter"

if [ "$rp_filter" -eq 0 ]; then
    echo "WARNING: rp_filter disabled."
    warning_count=$((warning_count+1))
fi

########################################
# 6. Listening TCP Services (Summary)
########################################
echo
echo "== Listening TCP Service Count =="

tcp_count=$(ss -tln 2>/dev/null | grep LISTEN | wc -l)
echo "Listening TCP sockets: $tcp_count"

if [ "$tcp_count" -gt 10 ]; then
    echo "WARNING: High number of listening TCP services."
    warning_count=$((warning_count+1))
fi

########################################
# Summary
########################################
echo
echo "===== Audit Summary ====="

if [ "$warning_count" -gt 0 ]; then
    echo "STATUS: WARNING - Network hardening improvements recommended."
    exit 1
else
    echo "STATUS: PASS - Network baseline normal."
    exit 0
fi
