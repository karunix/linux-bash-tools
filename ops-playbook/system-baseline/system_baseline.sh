#!/bin/bash

echo "===== SYSTEM BASELINE ====="
echo

echo "Hostname:"
hostname
echo

echo "Uptime:"
uptime
echo

echo "Kernel:"
uname -r
echo

echo "OS:"
cat /etc/os-release | grep PRETTY_NAME
echo

echo "CPU Load:"
uptime | awk -F'load average:' '{ print $2 }'
echo

echo "Memory Usage:"
free -h
echo

echo "Disk Usage:"
df -h
echo

echo "Top 5 Memory Processes:"
ps aux --sort=-%mem | head -n 6
echo

echo "Top 5 CPU Processes:"
ps aux --sort=-%cpu | head -n 6
echo

echo "Open Ports:"
ss -tuln
echo

echo "===== END BASELINE ====="
