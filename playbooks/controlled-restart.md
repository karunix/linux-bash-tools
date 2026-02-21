# Controlled Restart Playbook

## Purpose
Safely restart a service or application when:

- Automation has failed
- Service is unstable
- API version mismatch occurred
- Log errors persist
- System state appears degraded

This playbook avoids blind restarts.

---

## 1. Initial Triage

Run baseline first:

```bash
./quick_baseline.sh

Check:

System load

Memory pressure

Disk usage

Network state

If system is under heavy load, resolve that first.

2. Identify Service State
systemctl status <service>

Look for:

Failed state

Restart loops

Dependency failures

Exit codes

Check restart count:

systemctl show <service> --property=RestartCount

If restart count is climbing → investigate before restarting.

3. Review Logs
journalctl -u <service> -n 50 --no-pager

Look for:

Configuration errors

Port binding failures

Permission issues

API incompatibility

Database connection failures

Do NOT restart blindly if root cause is clear.

4. Graceful Stop
sudo systemctl stop <service>

Confirm:

systemctl status <service>

Ensure it is fully stopped before proceeding.

If application has its own shutdown script, use that instead.

5. Verify Ports Released
ss -tulnp | grep <port>

If port still bound:

Identify process

Ensure no orphaned processes remain

6. Start Service Cleanly
sudo systemctl start <service>

Immediately check:

systemctl status <service>
journalctl -u <service> -n 20 --no-pager

Watch for:

Crash loops

Immediate failures

Version mismatch errors

7. Validate Functionality

Confirm:

Service listening on expected port

API responding

Dependent services operational

External connectivity working (if applicable)

8. If Restart Fails

Do NOT repeatedly restart.

Instead:

Check configuration changes

Check package updates

Check disk space

Check expired certificates

Check firewall rules

Check dependency services

Escalate if required.

Key Principles

Never restart blindly.

Always check logs first.

Confirm ports free before start.

Validate after restart.

Restart is not a fix — it is a test.

When NOT to Restart

High system load

Disk full

Corrupt filesystem

Active data migration

Ongoing backup

Documentation

After successful restart:

Record time

Record reason

Record actions taken

Record log excerpts if relevant

Operational memory prevents repeat incidents.
