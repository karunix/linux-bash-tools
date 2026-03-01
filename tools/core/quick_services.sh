#!/bin/bash

########################################
# Quick Services Snapshot
# Purpose: Fast systemd service triage
########################################

echo "=============================="
echo " Quick Services Snapshot"
echo "=============================="
echo

########################################
# Failed Services
########################################
echo "Failed Services:"
failed=$(systemctl --failed --no-legend 2>/dev/null)

if [ -z "$failed" ]; then
    echo "None"
else
    echo "$failed"
fi

echo
########################################
# Recently Restarted Services
########################################
echo "Recently Restarted Services (Since Boot):"

systemctl list-units --type=service --state=running --no-legend 2>/dev/null | \
while read -r unit load active sub desc; do
    restarts=$(systemctl show "$unit" -p NRestarts 2>/dev/null | cut -d= -f2)
    if [ -n "$restarts" ] && [ "$restarts" -gt 0 ]; then
        printf "%-40s Restarts: %s\n" "$unit" "$restarts"
    fi
done

echo
########################################
# Core Service Status (If Installed)
########################################
echo "Core Service Status:"

core_services=("ssh.service" "sshd.service" "docker.service" "nginx.service" "apache2.service" "cron.service")

for svc in "${core_services[@]}"; do
    if systemctl list-unit-files 2>/dev/null | grep -q "^$svc"; then
        status=$(systemctl is-active "$svc" 2>/dev/null)
        printf "%-20s : %s\n" "$svc" "$status"
    fi
done

echo
echo "=============================="
