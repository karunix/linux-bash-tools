# Cloud Baseline Audit Playbook (V2)

## Objective

This playbook performs a baseline security audit for Linux servers typically deployed in cloud environments (AWS EC2, VPS, remote Ubuntu/Arch instances).

It focuses on identifying common misconfigurations that increase exposure risk.

This is not a compliance scanner. It is an operational security baseline review designed for sysadmin and contractor use.

---

# Audit Scope

## 1. Host Information

Why:
Understanding system identity is foundational in cloud environments.

Checks:
- Hostname

Command Used:
hostname

---

## 2. SSH Hardening (Effective Configuration)

Why:
SSH is the primary attack vector on cloud instances.

Instead of parsing sshd_config directly (which may contain commented or default values), this playbook evaluates the effective SSH configuration using:

sshd -T

This ensures accurate detection of active settings.

Checks:
- PermitRootLogin effective value
- PasswordAuthentication effective value

Fail Condition:
- PermitRootLogin = yes AND PasswordAuthentication = yes

This represents high-risk exposure (root login allowed via password).

---

## 3. Public TCP Exposure

Why:
Services bound to 0.0.0.0 or ::: are reachable on all network interfaces (subject to firewall rules).

The script detects only true public binds using filtered ss output.

Command Logic:
ss -tulnp

Filtered using awk to match:
- 0.0.0.0:
- [::]:

Warning Condition:
- Any TCP service listening on all interfaces.

Note:
Services bound to 127.0.0.1 are NOT considered public exposure.

---

## 4. UID 0 Accounts

Why:
Multiple UID 0 accounts represent privilege escalation risk.

Command Used:
awk -F: '($3 == 0)' /etc/passwd

Warning Condition:
- More than one UID 0 account detected.

---

## 5. Logging Baseline (Distro-Aware)

Why:
Logging is required for detection and forensic analysis.

The script checks for:

- systemd-journald (systemd-based distributions)
- rsyslog (common on Ubuntu)
- auditd (recommended for hardened systems)

Warning Condition:
- No active logging service detected.

Note:
auditd is recommended but not required for baseline PASS.

---

## 6. Firewall Status

Why:
Local firewall complements cloud security groups.

The script checks for:

- firewalld (Arch/RHEL-based systems)
- ufw (Ubuntu-based systems)

Warning Condition:
- No active firewall detected.

---

# Output Logic (V2)

PASS:
No high-risk exposure detected.

WARNING:
Hardening improvements recommended.

FAIL:
Critical exposure detected (e.g., root login with password authentication).

Exit Codes:
0 = PASS
1 = WARNING
2 = FAIL

---

# Usage

sudo ./cloud_baseline_audit.sh

After execution:

echo $?

---

# Investigation Guidance

If WARNING or FAIL:

1. Review effective SSH configuration:
   sshd -T

2. Restrict root login:
   Set PermitRootLogin prohibit-password or no.

3. Disable password authentication if appropriate:
   Set PasswordAuthentication no.

4. Review publicly bound services:
   ss -tulnp

5. Confirm firewall active:
   systemctl status firewalld
   or
   ufw status

6. Review UID 0 accounts:
   awk -F: '($3 == 0)' /etc/passwd

7. Enable auditd for hardened systems if required.

---

This playbook is designed for operational cloud hardening audits and contractor-level baseline reviews.
