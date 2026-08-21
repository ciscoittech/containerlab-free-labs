#!/bin/bash

echo "========================================="
echo "Cleaning up BGP eBGP Basics Lab"
echo "========================================="
echo ""

# Destroy containerlab topology
sudo containerlab destroy -t topology.clab.yml

# containerlab destroy can leave the management network behind. A stale
# network blocks the next lab from deploying, so remove it explicitly.
sudo docker network rm clab-bgp >/dev/null 2>&1 || true


echo ""
echo "Lab cleaned up successfully!"
echo ""
