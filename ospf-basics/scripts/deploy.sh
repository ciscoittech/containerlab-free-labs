#!/bin/bash

echo "========================================="
echo "Deploying OSPF Basics Lab"
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
echo "Access routers:"
echo "  docker exec -it clab-ospf-basics-r1 vtysh"
echo "  docker exec -it clab-ospf-basics-r2 vtysh"
echo "  docker exec -it clab-ospf-basics-r3 vtysh"
echo ""
echo "Run validation:"
echo "  ./scripts/validate.sh"
echo ""
echo "Cleanup:"
echo "  ./scripts/cleanup.sh"
echo ""
