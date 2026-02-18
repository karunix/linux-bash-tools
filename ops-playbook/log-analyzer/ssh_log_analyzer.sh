#!/bin/bash

# ssh_log_analyzer.sh
# Analyze SSH authentication failures using journalctl
# Supports IPv4 and IPv6
# Arch / systemd environment

LOG_DATA=$(journalctl -u sshd --no-pager 2>/dev/null)

FAIL_LINES=$(printf "%s\n" "$LOG_DATA" | grep -E "Failed password|Invalid user")

TOTAL_FAILS=$(printf "%s\n" "$FAIL_LINES" | grep -c .)

echo "===== SSH Failure Summary ====="
echo "Total Failed Attempts: $TOTAL_FAILS"
echo

if [ "$TOTAL_FAILS" -eq 0 ]; then
    echo "No failed SSH attempts found."
    exit 0
fi

echo "Top Offending IPs:"
printf "%s\n" "$FAIL_LINES" \
    | awk '{
        for(i=1;i<=NF;i++){
            if($i=="from"){
                print $(i+1)
            }
        }
    }' \
    | sort \
    | uniq -c \
    | sort -nr \
    | head -10

echo
echo "Targeted Usernames:"
printf "%s\n" "$FAIL_LINES" \
    | awk '{
        for(i=1;i<=NF;i++){
            # Case 1: Failed password for invalid user X
            if($i=="invalid" && $(i+1)=="user"){
                print $(i+2)
            }
            # Case 2: Failed password for root
            else if($i=="for" && $(i+1)!="invalid"){
                print $(i+1)
            }
            # Case 3: Invalid user X from ...
            else if($i=="Invalid" && $(i+1)=="user"){
                print $(i+2)
            }
        }
    }' \
    | sort \
    | uniq -c \
    | sort -nr \
    | head -10

echo
echo "Potential Brute Force Sources (10+ attempts):"
printf "%s\n" "$FAIL_LINES" \
    | awk '{
        for(i=1;i<=NF;i++){
            if($i=="from"){
                print $(i+1)
            }
        }
    }' \
    | sort \
    | uniq -c \
    | awk '$1 >= 10'

echo
echo "Analysis Complete."
