#!/bin/bash
# Cleanup Zero Trust Fundamentals Lab
#
# Stops all containers and removes volumes

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
LAB_DIR="$(dirname "$SCRIPT_DIR")"

echo "======================================"
echo "Cleaning up Zero Trust Fundamentals"
echo "======================================"
echo ""

cd "$LAB_DIR"

docker-compose down -v

echo ""
echo "Lab cleaned up successfully!"
echo ""
