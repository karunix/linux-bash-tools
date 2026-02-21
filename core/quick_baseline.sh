#!/bin/bash

echo "======================================"
echo " Quick Baseline Snapshot"
echo "======================================"

echo
echo "----- SYSTEM HEALTH -----"
echo
./quick_health.sh

echo
echo "----- NETWORK SNAPSHOT -----"
echo
./quick_network.sh

echo
echo "======================================"
