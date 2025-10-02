#!/bin/bash

echo "========================================="
echo "Deploying BGP eBGP Basics Lab"
echo "========================================="
echo ""

# Deploy containerlab topology
echo "Starting containerlab deployment..."
sudo containerlab deploy -t topology.clab.yml

echo ""
echo "========================================="
echo "Lab Deployed Successfully!"
echo "========================================="
echo ""
echo "Topology: AS 100 (r1, r4) <-> AS 200 (r2) <-> AS 300 (r3)"
echo ""
echo "Access routers:"
echo "  docker exec -it clab-bgp-ebgp-basics-r1 vtysh"
echo "  docker exec -it clab-bgp-ebgp-basics-r2 vtysh"
echo "  docker exec -it clab-bgp-ebgp-basics-r3 vtysh"
echo "  docker exec -it clab-bgp-ebgp-basics-r4 vtysh"
echo ""
echo "Run validation:"
echo "  ./scripts/validate.sh"
echo ""
echo "Cleanup:"
echo "  ./scripts/cleanup.sh"
echo ""
