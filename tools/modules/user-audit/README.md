# User Account Audit Playbook



## Scenario

Use this module when:

- Performing routine security audits
- Reviewing a newly deployed system
- Preparing for system handover
- Investigating potential privilege escalation
- Validating access control posture

This module analyzes local user configuration and highlights security risks.

No automatic modifications are performed.
Operator review is required.


---

## Objective

Identify:

- Multiple UID 0 accounts
- Unnecessary interactive shell access
- Misconfigured system/service accounts
- Unauthorized administrative privileges
- Suspicious or unexpected login activity

This tool answers:

Who has access?
Who has privilege?
Who should not?


---

## Data Sources

- /etc/passwd
- /etc/group
- system login records
- lastlog output


---

## Detection Strategy

1. Detect multiple UID 0 accounts
2. Identify accounts with interactive shells
3. Identify human login users (UID ≥ 1000)
4. Detect system accounts with interactive shells
5. Review administrative group membership
6. Review recent login activity
7. Provide summarized audit status


---

## Audit Checks


### 1. Detect Multiple UID 0 Accounts

Command:

awk -F: '$3 == 0 {print $1}' /etc/passwd

Expected:
Only:

root

Risk Interpretation:

Multiple UID 0 accounts indicate:

- Hidden administrative backdoors
- Privilege escalation risk
- Audit control failure

Remediation:

Lock account:

sudo passwd -l <username>

Remove account (if unauthorized):

sudo userdel <username>


---

### 2. Identify Accounts with Interactive Shells

Command:

awk -F: '$7 !~ /(nologin|false)/ {print $1 ":" $7}' /etc/passwd

Objective:

List all accounts capable of interactive login.

Risk Interpretation:

Service or application accounts with interactive shells:

- Increase attack surface
- Enable lateral movement
- May violate least-privilege principles

Remediation:

Modify shell:

sudo usermod -s /usr/bin/nologin <username>


---

### 3. Identify Human Login Users (UID ≥ 1000)

Command:

awk -F: '$3 >= 1000 && $7 ~ /(bash|sh)$/ {print $1 ":" $3 ":" $7}' /etc/passwd

Objective:

Identify legitimate human login accounts.

Review:

Confirm each user:

- Has a documented purpose
- Is currently authorized
- Requires shell access

Remediation:

Remove unused account:

sudo userdel <username>


---

### 4. Detect System Accounts with Interactive Shells

Command:

awk -F: '$3 > 0 && $3 < 1000 && $7 ~ /(bash|sh)$/ {print $1 ":" $3 ":" $7}' /etc/passwd

Risk Interpretation:

System accounts should not typically have interactive shells.

Interactive shells on service accounts may:

- Enable privilege escalation
- Provide unintended login paths

Remediation:

Restrict shell:

sudo usermod -s /usr/bin/nologin <username>


---

### 5. Review Administrative Group Membership

Command:

getent group wheel
getent group sudo

Objective:

Identify all users with elevated privileges.

Risk Interpretation:

Excessive administrative access increases:

- Configuration risk
- Abuse potential
- Lateral movement opportunity

Remediation:

Remove user from group:

sudo gpasswd -d <username> wheel

or

sudo gpasswd -d <username> sudo


---

### 6. Review Last Login Activity

Command:

lastlog -u <username>

Objective:

Investigate unusual login behavior.

Review:

- Unexpected recent logins
- Logins outside normal hours
- Dormant accounts becoming active

Remediation:

Lock account pending investigation:

sudo passwd -l <username>


---

## Script Summary Behavior

At the end of the script:

echo "Audit Summary:"
if [ "$WARNINGS" -eq 0 ]; then
    echo "STATUS: PASS - No critical warnings detected."
    exit 0
else
    echo "STATUS: WARNING - $WARNINGS issue(s) detected."
    exit 1
fi

Exit Codes:

0 → No critical findings
1 → Issues detected; review required

This allows:

- Integration into automation
- CI validation
- Periodic scheduled audits


---

## Operational Philosophy

This module:

- Does not modify accounts automatically
- Does not enforce policy silently
- Does not over-automate security decisions

It provides visibility.
The operator decides action.

Simple.
Transparent.
Auditable.


---

## Expansion Ideas

Future improvements may include:

- Detect accounts with empty passwords
- Detect password aging policy violations
- Identify locked vs unlocked accounts
- Export results to structured report file
- Compare against baseline user list

Keep improvements practical and explainable.
