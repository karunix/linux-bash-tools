# User Audit & Hardening Checklist

## Purpose
Audit local user accounts for privilege risks and interactive access exposure.

---

## 1. Check for Multiple UID 0 Accounts

Command:
awk -F: '$3 == 0 {print $1}' /etc/passwd

Expected:
Only "root"

Risk:
Multiple UID 0 accounts = privilege escalation risk.

---

## 2. Identify Accounts with Interactive Shells

Command:
awk -F: '$7 !~ /(nologin|false)/ {print $1 ":" $7}' /etc/passwd

Review:
Ensure each account requiring shell access is legitimate.

---

## 3. Identify Human Login Users

Command:
awk -F: '$3 >= 1000 && $7 ~ /(bash|sh)$/ {print $1 ":" $3 ":" $7}' /etc/passwd

Review:
Validate business purpose of each login-capable user.

---

## 4. Detect System Accounts with Interactive Shells

Command:
awk -F: '$3 > 0 && $3 < 1000 && $7 ~ /(bash|sh)$/ {print $1 ":" $3 ":" $7}' /etc/passwd

Risk:
Service accounts with shell access may expand attack surface.

---

## 5. Check Sudo Privileges

Command:
getent group wheel
getent group sudo

Review:
Confirm only authorized administrators have elevated access.
## 6. Review Last Login Activity

Command:
lastlog -u <username>

Review:
Investigate unexpected or recent login activity.

Summary section
At the very end of your script, add:

echo "Audit Summary:"
if [ "$WARNINGS" -eq 0 ]; then
    echo "STATUS: PASS - No critical warnings detected."
    exit 0
else
    echo "STATUS: WARNING - $WARNINGS issue(s) detected."
    exit 1
fi


