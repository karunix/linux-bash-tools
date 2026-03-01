#!/bin/bash

echo "=============================="
echo " Quick System Health"
echo "=============================="

echo
echo "Hostname:"
hostname

echo
echo "Uptime:"
uptime -p

echo
echo "Load Average:"
uptime | awk -F'load average:' '{print $2}'

echo
echo "Memory Usage:"
free -h | awk 'NR==2 {print "Used:", $3, "| Available:", $7}'

echo
echo "Disk Usage (Root Filesystem):"
df -h / | awk 'NR==2 {print "Used:", $3, "| Available:", $4, "| Usage:", $5}'

echo
echo "Top CPU Process:"
ps -eo pid,comm,%cpu --sort=-%cpu | awk 'NR==2'

echo
echo "Top Memory Process:"
ps -eo pid,comm,%mem --sort=-%mem | awk 'NR==2'

echo
echo "=============================="
