# Homelab Architecture

## Overview

This lab is designed for remote Linux systems administration practice.
Primary focus:
- Monitoring
- Automation
- Incident response

---

## Machines

### HP AIO
Role: Control Node
OS: EndeavourOS
IP Address: 192.168.1.155
Connection: Ethernet
Tools:
- Ansible
- Git
- SSH

---

### Dell Latitude
Role: Monitoring Server
OS: EndeavourOS
IP Address:192.168.1.177
Connection: Ethernet
Services:
- Docker
- Prometheus
- Grafana
- Alertmanager (if installed)

---

### Lenovo T480
Role: Test Node
OS: Arch (CLI)
IP Address:192.168.1.108
Connection: WiFi
Purpose:
- Incident simulation
- Bash toolkit testing
- Monitoring target

---

## Monitoring Flow

Lenovo + Dell → node_exporter → Prometheus (Dell) → Grafana

---

## Automation Flow

HP (Ansible control) → SSH → Dell & Lenovo
