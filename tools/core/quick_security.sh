#!/bin/bash

########################################
# Quick Security Snapshot
# Purpose: Fast exposure triage
########################################

echo "=============================="
echo " Quick Security Snapshot"
echo "=============================="
echo

########################################
# 1. Root Login SSH Setting
########################################
echo "SSH Root Login Setting:"

if [ -f /etc/ssh/sshd_config ]; then
    root_login=$(grep -Ei "^PermitRootLogin" /etc/ssh/sshd_config | awk '{print $2}')
    if [ -z "$root_login" ]; then
        echo "PermitRootLogin not explicitly set (defaults may apply)"
    else
        echo "PermitRootLogin: $root_login"
    fi
else
    echo "sshd_config not found"
fi

echo
########################################
# 2. Password Authentication Setting
########################################
echo "SSH Password Authentication:"

if [ -f /etc/ssh/sshd_config ]; then
    pass_auth=$(grep -Ei "^PasswordAuthentication" /etc/ssh/sshd_config | awk '{print $2}')
    if [ -z "$pass_auth" ]; then
        echo "PasswordAuthentication not explicitly set"
    else
        echo "PasswordAuthentication: $pass_auth"
    fi
fi

echo
########################################
# 3. Users with UID 0 (Root Privilege)
########################################
echo "Accounts with UID 0:"
awk -F: '($3 == 0) {print $1}' /etc/passwd

echo
########################################
# 4. Passwordless Sudo Users
########################################
echo "Passwordless Sudo Entries:"

grep -R "NOPASSWD" /etc/sudoers /etc/sudoers.d 2>/dev/null || echo "None found"

echo
########################################
# 5. World-Writable Files in /etc
########################################
echo "World-Writable Files in /etc:"

ww_files=$(find /etc -xdev -type f -perm -0002 2>/dev/null)

if [ -z "$ww_files" ]; then
    echo "None"
else
    echo "$ww_files"
fi

echo
########################################
# 6. Recently Created Users (Last 7 Days)
########################################
echo "Recently Modified User Accounts (Last 7 Days):"

find /etc -name "passwd" -mtime -7 2>/dev/null && echo "Check manually for user changes"

echo
echo "=============================="
