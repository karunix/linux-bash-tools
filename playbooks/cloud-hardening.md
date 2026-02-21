# Cloud Hardening Playbook

## Purpose
Provide a structured baseline hardening process for a Linux cloud server.

This is not a compliance document.  
This is a practical operational hardening checklist.

---

# 1. Initial Baseline

After provisioning:

1. SSH into the server.
2. Run:

./core/quick_baseline.sh

3. Confirm:
- Minimal services listening
- No unexpected public ports
- Default firewall state known

---

# 2. Update System

Apply updates immediately:


sudo apt update
sudo apt upgrade -y


Enable automatic security updates if appropriate.

---

# 3. SSH Hardening

Edit:

/etc/ssh/sshd_config


Recommended settings:

- Disable root login:

PermitRootLogin no

- Disable password authentication (if keys configured):

PasswordAuthentication no

- Use key-based authentication only.

Restart SSH:

sudo systemctl restart ssh


Confirm access works before closing session.

---

# 4. Firewall Configuration

Enable firewall:

UFW example:

sudo ufw default deny incoming
sudo ufw default allow outgoing
sudo ufw allow 22/tcp
sudo ufw enable


Allow only required ports.

Verify:

sudo ufw status verbose


---

# 5. Remove Unnecessary Services

List listening services:

ss -tulpn


Disable unused services:

sudo systemctl disable <service>
sudo systemctl stop <service>


Minimal surface area = safer system.

---

# 6. User and Privilege Review

- Remove unused accounts.
- Confirm sudo group members:

getent group sudo

- Enforce strong authentication policy.

---

# 7. Logging and Monitoring

Ensure:

- systemd journal active
- auth logs being written
- log rotation configured

Optional:
- Install fail2ban if public SSH exposed.

---

# 8. Network Exposure Review

Run:

./core/quick_network.sh


Confirm:

- Only required services exposed publicly.
- Databases not bound to 0.0.0.0.
- No unnecessary UDP services.

---

# 9. Backup Verification

Confirm:

- Snapshot or backup configured.
- Restore method tested.
- Backup frequency appropriate for workload.

---

# 10. Periodic Review

Monthly:

- Re-run baseline
- Review firewall rules
- Review user accounts
- Review exposed ports
- Apply updates

---

# Principle

Harden early.

Reduce attack surface.

Keep configuration simple.

Re-validate regularly.
