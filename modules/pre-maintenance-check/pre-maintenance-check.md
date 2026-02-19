# Pre-Maintenance Checklist

## Disk
df -h
df -h /

## memory
free -h

## Load
uptime
htop

## Services
systemctl status <service>

## Logs
tail -f /var/log/syslog
journalctl -xe

Check 1 – Multiple UID 0 Accounts
awk -F: '$7 ~ /(bash|sh)$/ {print $1 ":" $7}' /etc/passwd
Check 2 – Interactive Shell Accounts
awk -F: '$7 !~ /(nologin|false)/ {print $1 ":" $7}' /etc/passwd
Check 3 – Real Bash Users
awk -F: '$7 ~ /(bash|sh)$/ {print $1 ":" $7}' /etc/passwd


