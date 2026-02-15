#!/bin/bash

# ==========================================
# SSH Abuse Detector
# Detects excessive failed SSH login attempts
# ==========================================

THRESHOLD=3

# Check argument
if [ -z "$1" ]; then
    echo "Usage: $0 <logfile>"
    exit 1
fi

LOGFILE="$1"

# Check file exists
if [ ! -f "$LOGFILE" ]; then
    echo "Error: File not found."
    exit 1
fi

echo "SSH Abuse Detector Starting..."
echo "Analyzing file: $LOGFILE"
echo

# Count failed attempts
FAILED_COUNT=$(grep "Failed password" "$LOGFILE" | wc -l)

echo "Total failed login attempts: $FAILED_COUNT"
echo

# Extract and count IPs
grep "Failed password" "$LOGFILE" \
| awk '{for(i=1;i<=NF;i++) if($i=="from") print $(i+1)}' \
| sort \
| uniq -c \
| while read COUNT IP
do
    if [ "$COUNT" -ge "$THRESHOLD" ]; then
        echo "ALERT: $IP has $COUNT failed attempts"
    fi
done