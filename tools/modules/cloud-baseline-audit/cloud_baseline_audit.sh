#!/bin/bash

warning_count=0
fail_count=0

echo "===== Cloud Baseline Audit (V2) ====="
echo

########################################
# 1. Host Information
########################################
echo "== Host Information =="
hostname
echo

########################################
# 2. SSH Hardening (Effective Config)
########################################
echo "== SSH Effective Configuration =="

if command -v sshd >/dev/null 2>&1; then
    ssh_effective=$(sshd -T 2>/dev/null)

    permit_root=$(echo "$ssh_effective" | grep '^permitrootlogin' | awk '{print $2}')
    password_auth=$(echo "$ssh_effective" | grep '^passwordauthentication' | awk '{print $2}')

    echo "PermitRootLogin: $permit_root"
    echo "PasswordAuthentication: $password_auth"
    echo

    if [[ "$permit_root" == "yes" && "$password_auth" == "yes" ]]; then
        echo "FAIL: Root login with password authentication enabled."
        fail_count=$((fail_count+1))
    fi
else
    echo "sshd not found."
    warning_count=$((warning_count+1))
fi

########################################
# 3. TCP Exposure (Real Public Binds Only)
########################################
echo
echo "== Public TCP Exposure (0.0.0.0 / :::) =="

tcp_exposed=$(ss -tulnp 2>/dev/null | awk '
/LISTEN/ && ($5 ~ /^0\.0\.0\.0:/ || $5 ~ /^\[::\]:/)
')

if [ -n "$tcp_exposed" ]; then
    echo "$tcp_exposed"
    warning_count=$((warning_count+1))
else
    echo "No TCP services publicly exposed."
fi

########################################
# 4. UID 0 Accounts
########################################
echo
echo "== UID 0 Accounts =="

uid_zero=$(awk -F: '($3 == 0)' /etc/passwd)
echo "$uid_zero"

uid_zero_count=$(echo "$uid_zero" | wc -l)

if [ "$uid_zero_count" -gt 1 ]; then
    echo "WARNING: Multiple UID 0 accounts detected."
    warning_count=$((warning_count+1))
fi

########################################
# 5. Logging Baseline (Distro Aware)
########################################
echo
echo "== Logging Services =="

logging_ok=0

# journald (systemd default)
if systemctl is-active systemd-journald >/dev/null 2>&1; then
    echo "systemd-journald: ACTIVE"
    logging_ok=1
fi

# rsyslog (Ubuntu typical)
if systemctl is-active rsyslog >/dev/null 2>&1; then
    echo "rsyslog: ACTIVE"
    logging_ok=1
fi

if [ "$logging_ok" -eq 0 ]; then
    echo "WARNING: No active logging service detected."
    warning_count=$((warning_count+1))
fi

# auditd (optional but recommended)
if systemctl is-active auditd >/dev/null 2>&1; then
    echo "auditd: ACTIVE"
else
    echo "auditd: NOT ACTIVE (recommended for hardened systems)"
fi

########################################
# 6. Firewall Status
########################################
echo
echo "== Firewall Status =="

firewall_active=0

if systemctl is-active firewalld >/dev/null 2>&1; then
    echo "firewalld: ACTIVE"
    firewall_active=1
elif command -v ufw >/dev/null 2>&1 && ufw status | grep -q "Status: active"; then
    echo "ufw: ACTIVE"
    firewall_active=1
else
    echo "WARNING: No active firewall detected."
    warning_count=$((warning_count+1))
fi

########################################
# Summary
########################################
echo
echo "===== Audit Summary ====="

if [ "$fail_count" -gt 0 ]; then
    echo "STATUS: FAIL - Critical cloud security exposure detected."
    exit 2
elif [ "$warning_count" -gt 0 ]; then
    echo "STATUS: WARNING - Baseline hardening improvements required."
    exit 1
else
    echo "STATUS: PASS - Cloud baseline secure."
    exit 0
fi
