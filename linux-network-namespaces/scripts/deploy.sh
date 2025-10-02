#!/bin/bash

echo "========================================="
echo "Deploying Linux Network Namespaces Lab"
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
echo "Access containers:"
echo "  docker exec -it clab-netns-basics-host1 sh"
echo "  docker exec -it clab-netns-basics-router sh"
echo ""
echo "Run validation:"
echo "  ./scripts/validate.sh"
echo ""
echo "Cleanup:"
echo "  ./scripts/cleanup.sh"
echo ""
