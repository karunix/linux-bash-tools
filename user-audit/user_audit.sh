#!/bin/bash

echo "User Audit Starting..."
echo
echo "Checking for UID 0 accounts..."

UID_ZERO=$(awk -F: '$3 == 0 {print $1}' /etc/passwd)
UID_ZERO_COUNT=$(echo "$UID_ZERO" | wc -l)

echo "$UID_ZERO"
echo

if [ "$UID_ZERO_COUNT" -gt 1 ]; then
	echo "ALERT: Multiple UID 0 accounts detected!"
else
	echo "OK: Only root has UID 0."
fi

echo

echo "Checking for interactive shell accounts..."

INTERACTIVE_USERS=$(awk -F: '$7 !~ /(nologin|false)/ {print $1 ":" $7}' /etc/passwd)

echo "$INTERACTIVE_USERS"
echo

echo "Identifying human users with interactive shells..."

HUMAN_USERS=$(awk -F: '$3 >= 1000 && $7 ~ /(bash|sh)$/ {print $1 ":" $3 ":" $7}' /etc/passwd)

if [ -z "$HUMAN_USERS" ]; then
	echo "No human interactive users found."
else
	echo "$HUMAN_USERS"
fi

echo
echo "Checking for system accounts with interactive shells..."

SYSTEM_INTERACTIVE=$(awk -F: '$3 > 0 && $3 < 1000 && $7 ~ /(bash|sh)$/ {print $1 ":" $3 ":" $7}' /etc/passwd)

if [ -z "$SYSTEM_INTERACTIVE" ]; then
	echo "No system accounts with interactive shells found."
else
	echo "WARNING: System accounts with interactive shells:"
	echo "$SYSTEM_INTERACTIVE"
fi

echo
echo "Checking for users with sudo privileges..."

SUDO_GROUP=$(getent group wheel 2>/dev/null)

if [ -z "$SUDO_GROUP" ]; then
	SUDO_GROUP=$(getent group sudo 2>/dev/null)
fi

if [ -n "$SUDO_GROUP" ]; then
	SUDO_USERS=$(echo "$SUDO_GROUP" | awk -F: '{print $4}')
	if [ -z "$SUDO_USERS" ]; then
		echo "No users currently in sudo/wheel group."
	else
		echo "Users with sudo privileges:"
		echo "$SUDO_USERS"
	fi
else
	echo "No sudo or wheel group found."
fi

echo
echo "Checking last login for human users..."

for user in $(awk -F: '$3 >= 1000 && $7 ~ /(bash|sh)$/ {print $1}' /etc/passwd); do
	echo "Last login for $user:"
	lastlog -u "$user" | tail -n 1
	echo
done
