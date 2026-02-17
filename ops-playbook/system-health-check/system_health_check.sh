#!/bin/bash

LOAD_THRESHOLD=2.0
MEMORY_THRESHOLD=80
DISK_THRESHOLD=80

echo "System Health Check Starting..."
echo

echo "Uptime:"
uptime -p
echo

echo "Load Average:"
LOAD_OUTPUT=$(uptime | awk -F'load average:' '{print $2}')
echo "$LOAD_OUTPUT"

CURRENT_LOAD=$(echo "$LOAD_OUTPUT" | cut -d',' -f1 | xargs)

LOAD_ALERT=$(awk -v cur="$CURRENT_LOAD" -v threshold="$LOAD_THRESHOLD" 'BEGIN {if (cur > threshold) print 1; else print 0}')

if [ "$LOAD_ALERT" -eq 1 ]; then
	echo "WARNING: Load average exceeds threshold!"
fi
echo

echo "Memory Usage:"
MEMORY_USED_PERCENT=$(free | awk '/Mem:/ {printf("%.0f"), $3/$2 * 100}')
echo "$MEMORY_USED_PERCENT% used"

if [ "$MEMORY_USED_PERCENT" -ge "$MEMORY_THRESHOLD" ]; then
	echo "WARNING: Memory usage exceeds threshold!"
fi
echo

echo "Disk Usage (/):"
DISK_USED_PERCENT=$(df -h / | awk 'NR==2 {gsub("%",""); print $5}')
echo "$DISK_USED_PERCENT% used"

if [ "$DISK_USED_PERCENT" -ge "$DISK_THRESHOLD" ]; then
	echo "WARNING: Disk usage exceeds threshold!"
fi
echo

echo "System Health Check Complete."
