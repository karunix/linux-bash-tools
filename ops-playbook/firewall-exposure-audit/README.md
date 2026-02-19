Firewall Exposure Audit Playbook
1. Objective

Determine which services are listening on the system and whether they may be exposed to external networks.

This audit identifies:

Listening TCP/UDP ports

Services bound to all interfaces (0.0.0.0 / ::)

Firewall status and configuration

Potential unintended public exposure

2. Why This Matters

A service running is not automatically a risk.

A service listening on all interfaces without firewall restriction is a risk.

Attackers continuously scan public IP ranges looking for:

Open SSH (22)

Exposed databases (5432, 3306)

Redis (6379)

Elasticsearch (9200)

Debug services

Exposure analysis answers:

“What could be reachable from outside this system?”

3. Manual Inspection Commands

These are the raw commands used for investigation.

3.1 List Listening Ports
ss -tulnp


Explanation:

-t TCP

-u UDP

-l Listening

-n Numeric (no DNS)

-p Show process

Focus on:

0.0.0.0

::

Public IP addresses

Example risky output:

tcp LISTEN 0 128 0.0.0.0:5432


This means PostgreSQL is listening on all interfaces.

3.2 Identify Services Bound to All Interfaces
ss -tulnp | grep -E '0.0.0.0|:::'


These bindings accept traffic from any interface.

Investigate whether exposure is intentional.

3.3 Check Firewall Status (firewalld)
sudo systemctl status firewalld


Or:

sudo firewall-cmd --state


Expected secure state:

running


If inactive:

System relies entirely on upstream network controls.

3.4 List Active Firewall Rules
sudo firewall-cmd --list-all


Review:

Allowed ports

Active zones

Default policy

4. Risk Evaluation
Low Risk

Services bound to 127.0.0.1 only

Firewall active

Only required ports open

Medium Risk

Services bound to 0.0.0.0

Firewall active but overly permissive

High Risk

Services bound to 0.0.0.0

Firewall inactive

Database or admin services exposed

5. Hardening Actions
Bind Service to Localhost

Example (PostgreSQL):

Edit:

/var/lib/postgres/data/postgresql.conf


Set:

listen_addresses = 'localhost'


Restart:

sudo systemctl restart postgresql

Restrict via Firewall

Allow only specific source:

sudo firewall-cmd --add-rich-rule='rule family="ipv4" source address="10.0.0.0/24" port port="5432" protocol="tcp" accept'


Remove public exposure:

sudo firewall-cmd --remove-port=5432/tcp

Disable Unnecessary Services
sudo systemctl disable <service>
sudo systemctl stop <service>

6. Script Purpose

The accompanying script:

Automates listening port detection

Flags services bound to all interfaces

Verifies firewall state

Generates a summary status

It does not replace human analysis.

7. Exit Codes

0 = No high-risk exposure detected

1 = Potential exposure detected (review required)

Operational Note

Listening does not equal exposed.

Firewall configuration, NAT, and cloud security groups determine real external reachability.

Always confirm network topology before remediation.
