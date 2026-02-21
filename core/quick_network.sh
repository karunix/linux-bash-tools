#!/bin/bash

echo "=============================="
echo " Quick Network Snapshot"
echo "=============================="

echo
echo "IP Addresses:"
ip -brief addr show | awk '$1 != "lo" {print $1, $2, $3}'

echo
echo "Default Gateway:"
ip route | awk '/^default/ {print "Via:", $3, "| Interface:", $5; exit}'

echo
echo "Listening TCP Ports:"
ss -tln | awk 'NR>1 {print $4}'

echo
echo "Public Binds:"
ss -tln | awk '
/LISTEN/ && ($4 ~ /^0\.0\.0\.0:/ || $4 ~ /^\*:/ || $4 ~ /^\[::\]:/) {print $4}
'

echo
echo "DNS Servers:"
grep nameserver /etc/resolv.conf 2>/dev/null | awk '{print $2}'

echo
echo "=============================="
