#!/bin/bash
# Complete migration to cisco/cisco credentials
# Run this in GitHub Codespaces terminal

echo "=============================================="
echo "🔐 Migrating to cisco/cisco Credentials"
echo "=============================================="
echo ""

# Step 1: Pull latest changes
echo "[Step 1/6] Pulling latest changes from GitHub..."
git pull
echo "✓ Done"
echo ""

# Step 2: Destroy existing labs
echo "[Step 2/6] Destroying existing labs..."
if docker ps --format '{{.Names}}' | grep -q "clab-"; then
    cd bgp-ebgp-basics 2>/dev/null && clab destroy -t topology.clab.yml --cleanup 2>/dev/null
    cd ../ospf-basics 2>/dev/null && clab destroy -t topology.clab.yml --cleanup 2>/dev/null
    cd ../enterprise-vpn-migration 2>/dev/null && clab destroy -t topology.clab.yml --cleanup 2>/dev/null
    cd ..
    echo "✓ Labs destroyed"
else
    echo "✓ No labs running"
fi
echo ""

# Step 3: Remove old image
echo "[Step 3/6] Removing old frr-ssh image with admin/NokiaSrl1! credentials..."
if docker images | grep -q "frr-ssh"; then
    docker rmi frr-ssh:latest
    echo "✓ Old image removed"
else
    echo "✓ No old image to remove"
fi
echo ""

# Step 4: Rebuild with new credentials
echo "[Step 4/6] Building new frr-ssh image with cisco/cisco credentials..."
echo "This takes 2-3 minutes..."
./build-frr-ssh.sh
echo "✓ New image built"
echo ""

# Step 5: Verify image
echo "[Step 5/6] Verifying new image..."
if docker images | grep -q "frr-ssh"; then
    echo "✓ frr-ssh:latest image ready"
    docker images | grep frr-ssh
else
    echo "❌ ERROR: Image build failed"
    exit 1
fi
echo ""

# Step 6: Instructions
echo "[Step 6/6] Migration complete!"
echo ""
echo "=============================================="
echo "✅ Ready to Deploy Labs"
echo "=============================================="
echo ""
echo "Deploy a lab:"
echo "  cd bgp-ebgp-basics"
echo "  clab deploy -t topology.clab.yml"
echo "  sleep 10"
echo ""
echo "Test SSH with NEW credentials:"
echo "  ssh -p 2211 cisco@localhost"
echo "  Password: cisco"
echo ""
echo "Expected: You land at r1# immediately"
echo ""
echo "=============================================="
echo "🎉 Migration Complete!"
echo "=============================================="
