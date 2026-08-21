#!/bin/bash
# Deploy VyOS Firewall Basics Lab

# VyOS applies /run/sysctl/10-vyos-firewall.conf on every firewall commit, which
# touches net.bridge.bridge-nf-call-*. Those keys only exist once br_netfilter is
# loaded on the HOST — without it the commit fails and the firewall silently does
# nothing at all.
if ! lsmod 2>/dev/null | grep -q br_netfilter; then
    echo "Loading br_netfilter (required for VyOS firewall commits)..."
    sudo modprobe br_netfilter || echo "WARNING: could not load br_netfilter — the firewall will not enforce"
fi

set -e

echo "======================================"
echo "Deploying VyOS Firewall Basics Lab"
echo "======================================"
echo ""

# Check if containerlab is installed
if ! command -v containerlab &> /dev/null; then
    echo "ERROR: containerlab is not installed"
    echo "Install: https://containerlab.dev/install/"
    exit 1
fi

# Check if Docker is running
if ! docker info &> /dev/null; then
    echo "ERROR: Docker is not running"
    exit 1
fi

echo "Deploying lab topology..."
containerlab deploy -t topology.clab.yml

echo ""
echo "======================================"
echo "Lab Deployed Successfully!"
echo "======================================"
echo ""
echo "⚠️  IMPORTANT: VyOS takes 30-60 seconds to initialize"
echo ""
echo "Components:"
echo "  - fw1:      VyOS Firewall (2 zones: WAN/LAN)"
echo "  - client1:  LAN client (192.168.100.10)"
echo "  - internet: WAN host (172.16.10.100)"
echo ""
echo "Access VyOS:"
echo "  docker exec -it clab-vyos-firewall-basics-fw1 su - vyos"
echo ""
echo "Validate (wait 60 seconds first!):"
echo "  ./scripts/validate.sh"
echo ""
echo "Cleanup:"
echo "  ./scripts/cleanup.sh"
echo ""
