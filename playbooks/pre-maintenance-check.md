# Pre-Maintenance Check

## Purpose
Ensure the system is stable and safe before beginning maintenance work.

---

# 1. Confirm Identity

- Verify correct server:

hostname

- Confirm environment (prod, staging, dev).
- Confirm change window is approved.

Never assume you are on the correct machine.

---

# 2. Baseline Snapshot

Run:

./core/quick_baseline.sh


Confirm:

- Load is normal
- Memory available is healthy
- Disk not critically full
- No unexpected public ports

If system already unhealthy, investigate before making changes.

---

# 3. Confirm Backups

- Identify backup method.
- Confirm last successful backup.
- Confirm restore capability if possible.

Do not proceed without verified backup.

---

# 4. Confirm Access Recovery

- Ensure you have:
  - Sudo access
  - Root password (if required)
  - Console or out-of-band access (if remote system)

Avoid locking yourself out during changes.

---

# 5. Service Awareness

- Identify critical services running:

systemctl list-units --type=service --state=running

- Confirm which services will be affected.
- Notify stakeholders if required.

---

# 6. Rollback Plan Ready

Before starting, answer:

- What exactly am I changing?
- How do I revert it?
- How long will rollback take?

If rollback plan is unclear, stop and clarify.

---

# Principle

Never begin maintenance on a system that is:

- Already unstable
- Not backed up
- Not properly identified
- Without rollback planning
