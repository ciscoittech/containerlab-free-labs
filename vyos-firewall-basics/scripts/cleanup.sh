#!/bin/bash
# Cleanup VyOS Firewall Basics Lab

set -e

echo "======================================"
echo "Cleaning Up VyOS Firewall Basics Lab"
echo "======================================"
echo ""

if ! command -v containerlab &> /dev/null; then
    echo "ERROR: containerlab is not installed"
    exit 1
fi

echo "Destroying lab topology..."
containerlab destroy -t topology.clab.yml --cleanup

echo ""
echo "======================================"
echo "Lab Cleanup Complete"
echo "======================================"
echo ""
echo "To redeploy: ./scripts/deploy.sh"
echo ""
