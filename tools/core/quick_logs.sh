#!/bin/bash

########################################
# Quick Logs Snapshot
# Purpose: Fast error and auth triage
########################################

echo "=============================="
echo " Quick Logs Snapshot"
echo "=============================="
echo

########################################
# Recent System Errors
########################################
echo "Recent System Errors (Priority 3 - Errors):"
journalctl -p 3 -xb --no-pager 2>/dev/null | tail -n 20

echo
########################################
# SSH Authentication Failures
########################################
echo "Recent SSH Failed Logins:"

if [ -f /var/log/auth.log ]; then
    grep "Failed password" /var/log/auth.log | tail -n 10
elif [ -f /var/log/secure ]; then
    grep "Failed password" /var/log/secure | tail -n 10
else
    echo "Auth log not found."
fi

echo
########################################
# Disk / Filesystem Errors
########################################
echo "Recent Disk / Filesystem Errors:"

dmesg 2>/dev/null | grep -iE "I/O error|EXT4-fs error|XFS error|Buffer I/O error|read-only file system|SMART" | tail -n 10

echo
echo "=============================="
