#!/bin/bash

# persistence_audit.sh
# Detects common Linux persistence mechanisms
# Cron jobs, systemd services, timers, rc.local

WARNINGS=0

echo "===== Persistence Audit ====="
echo

# --------------------------------------------------
# 1. System-wide Crontab
# --------------------------------------------------
echo "== /etc/crontab =="

if [ -f /etc/crontab ]; then
    cat /etc/crontab
else
    echo "No /etc/crontab found."
fi
echo


# --------------------------------------------------
# 2. Cron Directories
# --------------------------------------------------
echo "== /etc/cron.* Directories =="

for dir in /etc/cron.hourly /etc/cron.daily /etc/cron.weekly /etc/cron.monthly; do
    if [ -d "$dir" ]; then
        echo "-- $dir --"
        ls -l "$dir"
    fi
done
echo


# --------------------------------------------------
# 3. User Crontabs
# --------------------------------------------------
echo "== User Crontabs =="

for user in $(cut -f1 -d: /etc/passwd); do
    CRON_OUTPUT=$(crontab -u "$user" -l 2>/dev/null)
    if [ -n "$CRON_OUTPUT" ]; then
        echo "-- Crontab for $user --"
        echo "$CRON_OUTPUT"
        WARNINGS=$((WARNINGS+1))
    fi
done

echo


# --------------------------------------------------
# 4. Enabled Systemd Services
# --------------------------------------------------
echo "== Enabled Systemd Services =="

systemctl list-unit-files --type=service --state=enabled
echo


# --------------------------------------------------
# 5. Systemd Timers
# --------------------------------------------------
echo "== Active Systemd Timers =="

systemctl list-timers --all
echo


# --------------------------------------------------
# 6. Custom Service Files (Non-standard Paths)
# --------------------------------------------------
echo "== Custom Systemd Service Files =="

CUSTOM_SERVICES=$(find /etc/systemd/system -type f -name "*.service")

if [ -n "$CUSTOM_SERVICES" ]; then
    echo "$CUSTOM_SERVICES"
    WARNINGS=$((WARNINGS+1))
else
    echo "No custom service files found."
fi

echo


# --------------------------------------------------
# 7. rc.local
# --------------------------------------------------
echo "== /etc/rc.local =="

if [ -f /etc/rc.local ]; then
    cat /etc/rc.local
    WARNINGS=$((WARNINGS+1))
else
    echo "No rc.local file found."
fi

echo


# --------------------------------------------------
# Summary
# --------------------------------------------------
echo "===== Audit Summary ====="

if [ "$WARNINGS" -eq 0 ]; then
    echo "STATUS: PASS - No obvious persistence mechanisms detected."
    exit 0
else
    echo "STATUS: WARNING - $WARNINGS potential persistence location(s) detected."
    exit 1
fi
