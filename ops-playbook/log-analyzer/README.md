# SSH Log Analyzer Playbook

## Scenario

Use this tool when:

- SSH brute-force is suspected
- Login abuse needs investigation
- Reviewing authentication activity during audits
- Performing routine system security checks

This module provides read-only analysis of SSH authentication failures.

No automated blocking.
No system modifications.
Operator-driven response.


---

## Objective

Identify:

- Total failed authentication attempts
- Top offending IP addresses
- Targeted usernames
- Repeated attempts indicating brute-force behavior

This tool answers:

Who is attacking?
What accounts are being targeted?
Is this random noise or concentrated abuse?


---

## Environment

Designed for:

- Arch / EndeavourOS
- systemd-based systems
- OpenSSH service (sshd)

Data source:

journalctl -u sshd


---

## Detection Strategy

1. Extract SSH logs using journalctl
2. Filter only:
   - "Failed password"
   - "Invalid user"
3. Count total failed attempts
4. Extract IP addresses following keyword "from"
5. Extract usernames from:
   - "Failed password for root"
   - "Failed password for invalid user X"
   - "Invalid user X from ..."
6. Rank results
7. Flag IPs with 10+ attempts


---

## Usage

Make executable:

chmod +x ssh_log_analyzer.sh

Run:

sudo ./ssh_log_analyzer.sh


---

## Output Interpretation Guide

### Total Failed Attempts

Low number (1–3):
- Likely manual mistake
- Or single connection test

Moderate number (5–20):
- Possible automated scanning

High number (50+):
- Likely brute-force attempt


---

### Top Offending IPs

Single IP with many attempts:
- Focused brute-force attack

Many IPs with low counts:
- Distributed scanning


---

### Targeted Usernames

Repeated attempts on one account:
- Targeted brute-force

Many usernames from one IP:
- Username enumeration

Root being targeted:
- System is visible to automated bots


---

## Follow-Up Actions (Manual Remediation)

These actions are NOT automated.
They are operator decisions based on findings.


---

### 1. Temporary Firewall Block (Immediate Containment)

#### Using iptables (IPv4)

sudo iptables -A INPUT -s 1.2.3.4 -j DROP

IPv6:

sudo ip6tables -A INPUT -s ::1 -j DROP

View rules:

sudo iptables -L -n --line-numbers

Note:
Rules may not persist after reboot unless saved.


---

#### Using nftables

IPv4:

sudo nft add rule inet filter input ip saddr 1.2.3.4 drop

IPv6:

sudo nft add rule inet filter input ip6 saddr ::1 drop

Persistent configuration typically stored in:

/etc/nftables.conf


---

#### Using ufw

sudo ufw deny from 1.2.3.4


---

### 2. Enable fail2ban (Automated Protection)

Install:

sudo pacman -S fail2ban

Enable service:

sudo systemctl enable --now fail2ban

Create or edit config:

sudo micro /etc/fail2ban/jail.local

Example minimal configuration:

[sshd]
enabled = true
maxretry = 5
bantime = 3600

Restart service:

sudo systemctl restart fail2ban

Check status:

sudo fail2ban-client status sshd


---

### 3. Harden SSH Configuration

Edit SSH configuration:

sudo nano /etc/ssh/sshd_config

Recommended security settings:

PermitRootLogin no
PasswordAuthentication no
MaxAuthTries 3
LoginGraceTime 30

After changes:

sudo systemctl restart sshd

Important:
If disabling password authentication, ensure SSH keys are configured first.


---

## Operational Philosophy

This module:

- Does not auto-block
- Does not modify system state
- Does not over-automate

It provides signal.
The operator decides the response.

Simple.
Transparent.
Expandable.


---

## Expansion Ideas

Future improvements may include:

- Time filtering (e.g. last 1 hour)
- Threshold flag configuration
- Detection of successful login after repeated failures
- Exporting results to file

Keep improvements minimal and understandable.
