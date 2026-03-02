#!/usr/bin/env bash
VERSION_FILE="/opt/linux-bash-tools/VERSION"

if [[ "$1" == "--version" ]]; then
    if [[ -f "$VERSION_FILE" ]]; then
        echo "quick_health v$(cat $VERSION_FILE)"
    else
        echo "Version file not found"
    fi
    exit 0
fi
set -euo pipefail

VERSION="1.0"
EXIT_STATUS=0

usage() {
    echo "quick_health.sh - Basic system health check"
    echo ""
    echo "Usage:"
    echo "  quick_health.sh"
    echo "  quick_health.sh -h"
    echo ""
    exit 0
}

if [[ "${1:-}" == "-h" ]]; then
    usage
fi

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
LOAD=$(uptime | awk -F'load average:' '{print $2}' | cut -d',' -f1 | xargs)
echo "$LOAD"

LOAD_INT=${LOAD%.*}
if [[ "$LOAD_INT" -gt 4 ]]; then
    echo "WARNING: High load detected"
    EXIT_STATUS=1
fi

echo
echo "Memory Usage:"
MEM_AVAILABLE=$(free -m | awk 'NR==2 {print $7}')
MEM_TOTAL=$(free -m | awk 'NR==2 {print $2}')
MEM_PERCENT=$(( (MEM_AVAILABLE * 100) / MEM_TOTAL ))
echo "Available: ${MEM_AVAILABLE}MB (${MEM_PERCENT}% free)"

if [[ "$MEM_PERCENT" -lt 20 ]]; then
    echo "WARNING: Low memory available"
    EXIT_STATUS=1
fi

echo
echo "Disk Usage (Root Filesystem):"
DISK_PERCENT=$(df / | awk 'NR==2 {print $5}' | tr -d '%')
echo "Usage: ${DISK_PERCENT}%"

if [[ "$DISK_PERCENT" -gt 85 ]]; then
    echo "WARNING: Disk usage high"
    EXIT_STATUS=1
fi

echo
echo "Top CPU Process:"
ps -eo pid,comm,%cpu --sort=-%cpu | awk 'NR==2'

echo
echo "Top Memory Process:"
ps -eo pid,comm,%mem --sort=-%mem | awk 'NR==2'

echo
echo "=============================="

exit $EXIT_STATUS
