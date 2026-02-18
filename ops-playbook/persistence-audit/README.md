Persistence Audit Playbook
Objective

Identify mechanisms that allow code execution to survive system reboot.

This module inspects common Linux persistence vectors including:

System-wide cron jobs

User crontabs

Cron directories

Enabled systemd services

Active systemd timers

Custom systemd service files

/etc/rc.local

Persistence is frequently used by attackers to maintain long-term access.

Operational Question

“What will execute automatically without administrator awareness?”

If a system is compromised, persistence almost always exists in one of these locations.

Data Sources Inspected
Category	Location / Command
System crontab	/etc/crontab
Scheduled scripts	/etc/cron.hourly, /etc/cron.daily, /etc/cron.weekly, /etc/cron.monthly
User crontabs	crontab -u <user> -l
Enabled services	systemctl list-unit-files --state=enabled
Timers	systemctl list-timers
Custom services	/etc/systemd/system/*.service
Legacy startup	/etc/rc.local
Risk Interpretation
1. User Crontabs

User-level cron jobs can execute arbitrary commands.
Investigate:

Unexpected shells

External scripts

Obfuscated commands

Encoded payloads

2. Custom Systemd Services

Services created under /etc/systemd/system/ may represent:

Application installs

Administrative automation

Or malicious persistence

Review:

Service description

ExecStart path

File ownership

File permissions

3. rc.local

Legacy startup method.
If present, ensure all commands are documented and legitimate.

Normal Findings

Expected on healthy systems:

Distribution default services enabled

Standard cron jobs (logrotate, updatedb, etc.)

No user crontabs (on hardened servers)

No unexpected timers

Suspicious Indicators

Services executing from:

/tmp

/dev/shm

Home directories

Cron jobs invoking:

bash -c

curl | bash

Encoded payloads

Timers running unknown binaries

Hidden or oddly named service files

Response Guidance

If suspicious persistence is identified:

Do not immediately delete it.

Document file path and contents.

Identify parent process and creator.

Review file timestamps (stat <file>).

Inspect related logs (journalctl -u <service>).

Preserve evidence before remediation.

Execution

Run with elevated privileges:

sudo ./persistence_audit.sh

Exit Codes
Code	Meaning
0	No obvious persistence mechanisms detected
1	One or more potential persistence locations identified
Operational Philosophy

This module does not assume compromise.
It provides visibility into auto-execution mechanisms.

Security posture improves when:

Startup logic is intentional

Automation is documented

Unexpected persistence is investigated
