#!/bin/bash

# process_audit.sh
# Runtime process inspection tool
# Detects suspicious execution patterns and exposed services

WARNINGS=0

echo "===== Process Audit ====="
echo

# --------------------------------------------------
# 1. Processes Running as Root (Informational)
# --------------------------------------------------
echo "== Processes Running as root =="

ps -eo user,pid,ppid,cmd --no-headers | awk '$1=="root"' || echo "None detected."
echo


# --------------------------------------------------
# 2. Processes Executing FROM /tmp or /dev/shm (Suspicious)
# --------------------------------------------------
echo "== Processes Executing from /tmp or /dev/shm =="

TEMP_PROCS=$(ps -eo pid,args --no-headers | awk '
{
    for(i=2;i<=NF;i++) {
        if($i ~ /^\/tmp/ || $i ~ /^\/dev\/shm/) {
            print $0
            break
        }
    }
}')

if [ -n "$TEMP_PROCS" ]; then
    echo "$TEMP_PROCS"
    WARNINGS=$((WARNINGS+1))
else
    echo "None detected."
fi
echo


# --------------------------------------------------
# 3. Processes with Deleted Binaries (High Risk)
# --------------------------------------------------
echo "== Processes with Deleted Binaries =="

DELETED_PROCS=$(lsof +L1 2>/dev/null)

if [ -n "$DELETED_PROCS" ]; then
    echo "$DELETED_PROCS"
    WARNINGS=$((WARNINGS+1))
else
    echo "None detected."
fi
echo


# --------------------------------------------------
# 4. Listening Network Services (Informational)
# --------------------------------------------------
echo "== Listening Network Services =="

ss -tulnp 2>/dev/null || echo "Unable to retrieve listening services."
echo


# --------------------------------------------------
# 5. Orphaned Processes (PPID = 1) (Informational)
# --------------------------------------------------
echo "== Orphaned Processes (PPID = 1) =="

ps -eo pid,ppid,user,cmd --no-headers | awk '$2==1' || echo "None detected."
echo


# --------------------------------------------------
# Summary
# --------------------------------------------------
echo "===== Audit Summary ====="

if [ "$WARNINGS" -eq 0 ]; then
    echo "STATUS: PASS - No critical findings."
fi
