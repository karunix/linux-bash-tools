# Maintenance Checklist

## Purpose
Provide a structured process before, during, and after performing maintenance on a Linux server.

---

# 1. Pre-Maintenance Checks

1. SSH into the server.
2. Run baseline snapshot:

./core/quick_baseline.sh

3. Confirm:
- Load is normal
- Memory not exhausted
- Disk not near 100%
- No suspicious public ports
4. Confirm correct server (hostname check).
5. Confirm maintenance window approved.

---

# 2. Backup Verification

Before making changes:

- Confirm which backup system protects this server.
- Identify:
  - Backup method (rsync, snapshot, cloud, etc.)
  - Backup destination
  - Last successful backup date
- Verify restore capability if possible.

Never assume backups exist. Confirm explicitly.
---

# 3. Change Execution

Examples:
- Package updates
- Configuration changes
- Service restarts
- Firewall modifications

During changes:

- Change one component at a time.
- Monitor service status:

systemctl status <service>

- Watch logs:

journalctl -xe


---

# 4. Post-Change Validation

Immediately after changes:

1. Re-run:

./core/quick_baseline.sh

2. Confirm:
- Services running
- No new unexpected ports
- Load stable
- No disk or memory spikes

3. Test application functionality (if applicable).

---

# 5. Rollback Plan

If something fails:

- Revert configuration changes.
- Restore from backup if necessary.
- Restart affected services.
- Document what failed.

Never leave system in unknown state.

---

# 6. Documentation

After successful maintenance:

- Record:
- Date
- Changes made
- Commands used
- Any anomalies observed
- Update internal ticketing system.

---

# Principles

- Validate before changing.
- Change slowly and deliberately.
- Validate after changing.
- Always have rollback.
