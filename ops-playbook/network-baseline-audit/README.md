# Network Baseline Audit Playbook

## Objective

This playbook performs an opinionated network posture baseline review for Linux systems.

It evaluates network configuration, routing, DNS, and kernel-level networking parameters
that may introduce exposure or misconfiguration risks.

This module does not modify system settings. It is read-only.

---

# Audit Scope

## 1. Network Interfaces & IP Addressing

Why:
Understanding active interfaces and IP assignments helps identify
unexpected public exposure or multi-homed configurations.

Checks:
- Active interfaces
- Assigned IPv4 addresses
- Public IPv4 detection

Warning Conditions:
- Public IPv4 address detected on host

---

## 2. Default Gateway & Routing

Why:
Incorrect routing can expose internal services or cause traffic leakage.

Checks:
- Default route
- Multiple default routes

Warning Conditions:
- Multiple default routes detected
- No default route detected

---

## 3. DNS Configuration

Why:
DNS misconfiguration can impact availability and security.

Checks:
- /etc/resolv.conf content
- Number of configured nameservers

Warning Conditions:
- No nameservers configured
- Excessive nameservers (more than 3)

---

## 4. IP Forwarding

Why:
IP forwarding enables routing behavior and is not required for most cloud instances.

Checks:
- net.ipv4.ip_forward
- net.ipv6.conf.all.forwarding

Warning Condition:
- IP forwarding enabled

---

## 5. Reverse Path Filtering (rp_filter)

Why:
Reverse path filtering helps prevent IP spoofing attacks.

Checks:
- net.ipv4.conf.all.rp_filter

Warning Condition:
- rp_filter disabled (0)

---

## 6. Listening TCP Services (Summary)

Why:
High numbers of listening services increase attack surface.

Checks:
- Total LISTEN TCP sockets

Warning Condition:
- More than 10 listening TCP services

---

# Output Logic

PASS:
Network baseline configuration appears normal.

WARNING:
One or more network hardening improvements recommended.

Exit Codes:
0 = PASS
1 = WARNING

---

# Usage

sudo ./network_baseline_audit.sh

Check exit code:

echo $?

---

This playbook is designed for cloud baseline and infrastructure security reviews.
