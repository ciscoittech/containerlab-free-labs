#!/bin/bash
# Quick test for SSH auto-login to router CLI

echo "============================================"
echo "Testing BGP eBGP Basics Lab - SSH Auto-Login"
echo "============================================"
echo ""

# Check if lab is running
if ! docker ps --format '{{.Names}}' | grep -q "clab-bgp-ebgp-basics-r1"; then
    echo "⚠️  Lab not running. Deploying now..."
    echo ""
    ./scripts/deploy.sh
    echo ""
    echo "Waiting 10 seconds for services to initialize..."
    sleep 10
else
    echo "✓ Lab is already running"
fi

echo ""
echo "============================================"
echo "SSH Access Test"
echo "============================================"
echo ""
echo "Testing SSH to r1 (AS 100) on port 2211..."
echo ""
echo "Expected behavior:"
echo "  - You should land DIRECTLY at: r1#"
echo "  - NOT at bash shell: admin@r1$"
echo ""
echo "Try this command:"
echo ""
echo "  ssh -p 2211 admin@localhost"
echo "  Password: NokiaSrl1!"
echo ""
echo "Once logged in, try:"
echo "  r1# show ip bgp summary"
echo "  r1# show ip route"
echo "  r1# exit  (this exits SSH completely)"
echo ""
echo "============================================"
echo "All 4 Routers Available:"
echo "============================================"
echo ""
echo "  r1 (AS 100): ssh -p 2211 admin@localhost"
echo "  r2 (AS 200): ssh -p 2212 admin@localhost"
echo "  r3 (AS 300): ssh -p 2213 admin@localhost"
echo "  r4 (AS 100): ssh -p 2214 admin@localhost"
echo ""
echo "Password for all: NokiaSrl1!"
echo ""
