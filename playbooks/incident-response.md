# Incident Response Playbook

## Purpose
Provide a calm, structured approach to triaging a potentially compromised or unstable Linux server.

---

# 1. Initial Triage (Do Not Panic)

1. SSH into the server.
2. Run:

./core/quick_baseline.sh

3. Screenshot or copy output immediately.

Assess:
- High load?
- Memory exhaustion?
- Disk full?
- Unexpected public ports?
- Unknown processes?

---

# 2. Immediate Containment (If Required)

If active compromise suspected:

- Do NOT reboot immediately.
- Do NOT start deleting files.
- Consider removing from network:
- Disable interface
- Remove default gateway
- Block inbound via firewall

Only isolate if necessary.

---

# 3. Process Review

Check for:

- Unknown processes
- Suspicious high CPU usage
- Unusual parent-child relationships

Commands:

ps aux --sort=-%cpu | head
ps aux --sort=-%mem | head


Investigate unknown binaries:

which <binary>
ls -lah <binary>


---

# 4. Network Exposure Review

Run:

./core/quick_network.sh


Look for:
- Public binds (*:)
- Unexpected listening ports
- Database ports exposed publicly
- SSH exposed to 0.0.0.0

If suspicious:

ss -tulpn


---

# 5. Authentication Review

Check recent logins:

last -a


Check failed SSH attempts:

sudo grep "Failed password" /var/log/auth.log | tail


Look for:
- Unknown IP addresses
- Brute force patterns
- Successful login from strange IP

---

# 6. Persistence Checks

Inspect:

- Cron jobs:

crontab -l
sudo ls /etc/cron*


- Startup services:

systemctl list-unit-files --type=service


Look for unknown or suspicious entries.

---

# 7. File System Review (If Suspicious Activity Found)

Look for recently modified files:

sudo find / -mtime -1 -type f 2>/dev/null


Check for unusual SUID binaries:

sudo find / -perm -4000 -type f 2>/dev/null


---

# 8. Escalation

If confirmed compromise:

- Document findings
- Preserve logs
- Notify senior staff
- Follow company policy
- Do not attempt deep remediation without approval

---

# Principles

- Stay calm.
- Collect evidence before changing system state.
- Avoid unnecessary reboots.
- Document everything.
