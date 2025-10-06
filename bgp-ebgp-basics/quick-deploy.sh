#!/bin/bash
# Quick deploy script for GitHub Codespaces (no sudo required)

echo "======================================"
echo "Deploying BGP eBGP Basics Lab"
echo "======================================"
echo ""

# Check if frr-ssh image exists
if ! docker images | grep -q "frr-ssh"; then
    echo "❌ ERROR: frr-ssh:latest image not found"
    echo ""
    echo "Please build the image first:"
    echo "  cd /workspaces/claude/sr_linux/labs/.claude-library/docker-images/frr-ssh"
    echo "  docker buildx build --platform linux/amd64 --load -t frr-ssh:latest ."
    echo ""
    exit 1
fi

echo "✓ frr-ssh:latest image found"
echo ""

# Deploy using containerlab (via alias in Codespaces)
echo "Deploying lab topology..."
clab deploy -t topology.clab.yml

echo ""
echo "======================================"
echo "Lab Deployed!"
echo "======================================"
echo ""
echo "Wait 10 seconds for FRR daemons to start, then try:"
echo ""
echo "  ssh -p 2211 admin@localhost"
echo "  Password: NokiaSrl1!"
echo ""
echo "You should land directly at: r1#"
echo ""
