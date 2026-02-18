# Log Analyzer - SSH Failure Inspection

## Purpose

Analyze SSH authentication failures using journalctl.

Designed for:
- Quick inspection under pressure
- Identifying brute-force attempts
- Understanding login abuse patterns

Environment:
- Arch-based systems (sshd via systemd)
- Uses: journalctl, grep, awk, sort, uniq

---

## Data Source

journalctl -u sshd --no-pager

Filters:
- "Failed password"
- "Invalid user"

---

## Detection Logic

1. Count total failed attempts
2. Extract IP addresses from "from <IP>"
3. Rank top offending IPs
4. Extract targeted usernames from "for <user>"
5. Flag IPs with 10+ failed attempts

No automation.
No alerting.
Read-only analysis tool.

---

## Usage

chmod +x ssh_log_analyzer.sh
./ssh_log_analyzer.sh
