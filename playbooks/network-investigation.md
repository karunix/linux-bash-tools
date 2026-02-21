# Network Investigation Playbook

## Purpose
Provide a structured approach when unusual network behavior or exposure is detected.

---

# 1. Initial Snapshot

Run:

./core/quick_network.sh


Identify:

- Unexpected public binds (*:)
- Unknown listening ports
- Missing default gateway
- Incorrect DNS configuration
- Unexpected interfaces (VPN, Docker, bridges)

Document findings before changing anything.

---

# 2. Port Investigation

If unknown port detected:

Identify owning process:

sudo ss -tulpn | grep <port>


Confirm binary path:

which <process>
ls -lah $(which <process>)


Check service:

systemctl status <service>


Determine:
- Expected?
- Part of installed software?
- Misconfiguration?
- Malicious?

---

# 3. Public Exposure Review

If service bound to 0.0.0.0 or *:

Confirm necessity:
- Should this be publicly reachable?
- Should it bind only to localhost?

If exposure not required:
- Adjust service bind address
- Restrict via firewall
- Disable service if unnecessary

---

# 4. Firewall Verification

Check firewall status:

UFW:

sudo ufw status verbose


iptables:

sudo iptables -L -n -v


Confirm:
- Default policy
- Open ports align with intended services

---

# 5. DNS Issues

If resolution failing:

Test:

ping google.com


If failing:
- Inspect /etc/resolv.conf
- Confirm correct nameservers
- Check systemd-resolved status:

systemctl status systemd-resolved


---

# 6. Gateway and Routing Problems

If no connectivity:

Check default route:

ip route


Test gateway:

ping <gateway_ip>


Confirm interface state:

ip link show


---

# 7. Suspicious Outbound Connections

Review active connections:

ss -tunap


Look for:
- Unknown remote IPs
- High-volume outbound traffic
- Persistent connections to unfamiliar hosts

Investigate owning process before terminating.

---

# 8. Escalation

If confirmed malicious activity:

- Preserve logs
- Isolate system if required
- Notify appropriate authority
- Follow incident response procedure
