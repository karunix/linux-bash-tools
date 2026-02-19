# Process Audit Playbook

## Scenario

Use this module when:

- Investigating suspected compromise
- Reviewing system runtime posture
- Preparing for production validation
- Conducting periodic operational audits
- Validating unexpected system behavior

This module inspects currently running processes and network exposure.

No automatic remediation is performed.


---

## Objective

Identify:

- Privileged processes
- Suspicious execution locations
- Deleted-but-running binaries
- Network-exposed services
- Orphaned processes

This tool answers:

What is running?
Who owns it?
Should it be there?


---

## Data Sources

- ps
- ss
- /proc
- lsof


---

## Detection Strategy

1. List processes running as root
2. Detect processes executing from temporary directories
3. Identify processes with deleted binaries
4. Display listening ports and owning processes
5. Detect orphaned processes (PPID = 1)
6. Provide summary status


---

## Audit Checks


### 1. Processes Running as Root

Command:

ps -eo user,pid,ppid,cmd --sort=user | grep '^root'

Objective:

Identify privileged execution.

Risk Interpretation:

Unexpected root-owned processes may indicate:

- Privilege escalation
- Service misconfiguration
- Malicious execution


---

### 2. Processes Running from Temporary Directories

Command:

ps -eo pid,cmd | grep -E '(/tmp|/dev/shm)'

Risk Interpretation:

Executables in temporary directories may indicate:

- Dropped payloads
- Unauthorized script execution
- Malware staging


---

### 3. Processes with Deleted Binaries

Command:

lsof +L1

Objective:

Identify running processes whose executable file has been removed.

Risk Interpretation:

Deleted-but-running binaries may indicate:

- Attempted stealth persistence
- Manual tampering
- Partial cleanup after compromise


---

### 4. Listening Network Services

Command:

ss -tulnp

Objective:

Identify services exposed on network ports.

Review:

- Unexpected listening ports
- Services bound to 0.0.0.0
- Unknown binaries owning ports


---

### 5. Orphaned Processes (PPID = 1)

Command:

ps -eo pid,ppid,user,cmd | awk '$2 == 1'

Objective:

Identify processes adopted by init/systemd.

Risk Interpretation:

Unexpected orphan processes may indicate:

- Improper service handling
- Background persistence attempts


---

## Script Summary Behavior

At the end of the script:

echo "Audit Summary:"
if [ "$WARNINGS" -eq 0 ]; then
    echo "STATUS: PASS - No critical findings."
    exit 0
else
    echo "STATUS: WARNING - $WARNINGS issue(s) detected."
    exit 1
fi

Exit Codes:

0 → No significant findings
1 → Findings require review


---

## Follow-Up Actions

This module does not auto-kill processes.

Operator decisions may include:

- Investigate process details:
  ps -fp <PID>

- Inspect binary location:
  ls -l /proc/<PID>/exe

- Kill suspicious process:
  sudo kill -9 <PID>

- Disable unauthorized service:
  sudo systemctl disable <service>

Always verify legitimacy before termination.


---

## Operational Philosophy

This module:

- Does not kill processes automatically
- Does not assume malicious intent
- Does not over-automate response

It provides visibility.
The operator decides.

Simple.
Explainable.
Expandable.


---

## Expansion Ideas

Future improvements may include:

- High CPU process detection
- High memory consumption detection
- Parent-child process tree visualization
- Comparison against baseline process list
- Export to report file
