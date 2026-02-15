# SSH Abuse Detector

Detects excessive failed SSH login attempts from log files.

## Usage

./detect_ssh_abuse.sh <logfile>

## Description

- Counts total failed login attempts
- Extracts source IP addresses
- Alerts when an IP exceeds the defined threshold

## Example

./detect_ssh_abuse.sh test.log
