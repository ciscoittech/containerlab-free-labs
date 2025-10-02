#!/bin/bash

echo "========================================="
echo "Cleaning up Linux Network Namespaces Lab"
echo "========================================="
echo ""

# Destroy containerlab topology
sudo containerlab destroy -t topology.clab.yml

echo ""
echo "Lab cleaned up successfully!"
echo ""
