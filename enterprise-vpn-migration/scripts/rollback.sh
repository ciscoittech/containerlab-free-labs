#!/bin/bash
#############################################################################
# Enterprise VPN Migration Lab - Rollback Script
#############################################################################
#
# Purpose: Rollback to pre-migration VPN configuration
#
# This script reverses the VPN migration and restores original configuration:
#   - Removes new GRE tunnel (gre1 with new IPs)
#   - Restores old GRE tunnel (gre0 with old IPs)
#   - Removes new WAN IPs
#   - Restores old WAN IPs
#
# Usage: ./scripts/rollback.sh
#
#############################################################################

set -e

# Color codes
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

echo ""
echo -e "${RED}=========================================${NC}"
echo -e "${RED}VPN Migration Rollback${NC}"
echo -e "${RED}=========================================${NC}"
echo ""

echo -e "${YELLOW}⚠ WARNING: This will rollback VPN migration${NC}"
echo ""
echo "This will revert to original VPN configuration:"
echo "  OLD (restore): Site A 203.0.113.10 ↔ Site B 198.51.100.10"
echo "  NEW (remove):  Site A 192.0.2.10 ↔ Site B 192.0.2.20"
echo ""
echo -e "${RED}Expected Downtime: 2-3 minutes${NC}"
echo ""
echo "Press Ctrl+C to cancel, or Enter to continue..."
read

# Track rollback start time
ROLLBACK_START=$(date +%s)

echo ""
echo -e "${BLUE}========== Phase 1: Remove New Tunnel from OSPF ==========${NC}"
echo ""

echo -e "${YELLOW}[1.1] Removing gre1 from OSPF on router-a1...${NC}"
docker exec clab-enterprise-vpn-migration-router-a1 vtysh -c "conf t" -c "interface gre1" -c "no ip ospf area 0" -c "end"
echo -e "${GREEN}✓ Done${NC}"

echo -e "${YELLOW}[1.2] Removing gre1 from OSPF on router-b1...${NC}"
docker exec clab-enterprise-vpn-migration-router-b1 vtysh -c "conf t" -c "interface gre1" -c "no ip ospf area 0" -c "end"
echo -e "${GREEN}✓ Done${NC}"

echo ""
echo -e "${BLUE}========== Phase 2: Recreate Old GRE Tunnel ==========${NC}"
echo ""

echo -e "${YELLOW}[2.1] Recreating gre0 on router-a1 (old IPs)...${NC}"
docker exec clab-enterprise-vpn-migration-router-a1 ip tunnel add gre0 mode gre remote 198.51.100.10 local 203.0.113.10 ttl 255
docker exec clab-enterprise-vpn-migration-router-a1 ip addr add 172.16.0.1/30 dev gre0
docker exec clab-enterprise-vpn-migration-router-a1 ip link set gre0 up
docker exec clab-enterprise-vpn-migration-router-a1 ip link set gre0 mtu 1400
echo -e "${GREEN}✓ Done${NC}"

echo -e "${YELLOW}[2.2] Recreating gre0 on router-b1 (old IPs)...${NC}"
docker exec clab-enterprise-vpn-migration-router-b1 ip tunnel add gre0 mode gre remote 203.0.113.10 local 198.51.100.10 ttl 255
docker exec clab-enterprise-vpn-migration-router-b1 ip addr add 172.16.0.2/30 dev gre0
docker exec clab-enterprise-vpn-migration-router-b1 ip link set gre0 up
docker exec clab-enterprise-vpn-migration-router-b1 ip link set gre0 mtu 1400
echo -e "${GREEN}✓ Done${NC}"

echo -e "${YELLOW}[2.3] Testing old tunnel connectivity...${NC}"
docker exec clab-enterprise-vpn-migration-router-a1 ping -c 3 172.16.0.2
echo -e "${GREEN}✓ Old tunnel operational${NC}"

echo ""
echo -e "${BLUE}========== Phase 3: Restore OSPF on Old Tunnel ==========${NC}"
echo ""

echo -e "${YELLOW}[3.1] Adding gre0 to OSPF on router-a1...${NC}"
docker exec clab-enterprise-vpn-migration-router-a1 vtysh -c "conf t" -c "interface gre0" -c "ip ospf area 0" -c "ip ospf network point-to-point" -c "ip ospf cost 100" -c "end"
echo -e "${GREEN}✓ Done${NC}"

echo -e "${YELLOW}[3.2] Adding gre0 to OSPF on router-b1...${NC}"
docker exec clab-enterprise-vpn-migration-router-b1 vtysh -c "conf t" -c "interface gre0" -c "ip ospf area 0" -c "ip ospf network point-to-point" -c "ip ospf cost 100" -c "end"
echo -e "${GREEN}✓ Done${NC}"

echo -e "${YELLOW}[3.3] Waiting 10 seconds for OSPF convergence...${NC}"
sleep 10
echo -e "${GREEN}✓ OSPF converged${NC}"

echo ""
echo -e "${BLUE}========== Phase 4: Remove New Tunnel ==========${NC}"
echo ""

echo -e "${YELLOW}[4.1] Shutting down new tunnel on router-a1...${NC}"
docker exec clab-enterprise-vpn-migration-router-a1 ip link set gre1 down 2>/dev/null || true
echo -e "${GREEN}✓ Done${NC}"

echo -e "${YELLOW}[4.2] Deleting new tunnel on router-a1...${NC}"
docker exec clab-enterprise-vpn-migration-router-a1 ip tunnel del gre1 2>/dev/null || true
echo -e "${GREEN}✓ Done${NC}"

echo -e "${YELLOW}[4.3] Shutting down new tunnel on router-b1...${NC}"
docker exec clab-enterprise-vpn-migration-router-b1 ip link set gre1 down 2>/dev/null || true
echo -e "${GREEN}✓ Done${NC}"

echo -e "${YELLOW}[4.4] Deleting new tunnel on router-b1...${NC}"
docker exec clab-enterprise-vpn-migration-router-b1 ip tunnel del gre1 2>/dev/null || true
echo -e "${GREEN}✓ Done${NC}"

echo ""
echo -e "${BLUE}========== Phase 5: Restore Old WAN IPs ==========${NC}"
echo ""

echo -e "${YELLOW}[5.1] Restoring old WAN IP on router-a1 (203.0.113.10)...${NC}"
docker exec clab-enterprise-vpn-migration-router-a1 ip addr add 203.0.113.10/30 dev eth2 2>/dev/null || echo "  (IP already present)"
echo -e "${GREEN}✓ Done${NC}"

echo -e "${YELLOW}[5.2] Restoring old WAN IP on router-b1 (198.51.100.10)...${NC}"
docker exec clab-enterprise-vpn-migration-router-b1 ip addr add 198.51.100.10/30 dev eth2 2>/dev/null || echo "  (IP already present)"
echo -e "${GREEN}✓ Done${NC}"

echo -e "${YELLOW}[5.3] Removing new WAN IP from router-a1 (192.0.2.10)...${NC}"
docker exec clab-enterprise-vpn-migration-router-a1 ip addr del 192.0.2.10/30 dev eth2 2>/dev/null || echo "  (IP already removed)"
echo -e "${GREEN}✓ Done${NC}"

echo -e "${YELLOW}[5.4] Removing new WAN IP from router-b1 (192.0.2.20)...${NC}"
docker exec clab-enterprise-vpn-migration-router-b1 ip addr del 192.0.2.20/30 dev eth2 2>/dev/null || echo "  (IP already removed)"
echo -e "${GREEN}✓ Done${NC}"

# Calculate rollback time
ROLLBACK_END=$(date +%s)
ROLLBACK_DURATION=$((ROLLBACK_END - ROLLBACK_START))

echo ""
echo -e "${BLUE}========== Phase 6: Final Validation ==========${NC}"
echo ""

echo -e "${YELLOW}[6.1] Verifying WAN configuration on router-a1...${NC}"
docker exec clab-enterprise-vpn-migration-router-a1 ip addr show eth2 | grep "inet " | sed 's/^/  /'
echo -e "${GREEN}✓ Done${NC}"

echo -e "${YELLOW}[6.2] Verifying GRE tunnel on router-a1...${NC}"
docker exec clab-enterprise-vpn-migration-router-a1 ip tunnel show gre0 | sed 's/^/  /'
echo -e "${GREEN}✓ Done${NC}"

echo -e "${YELLOW}[6.3] Testing end-to-end connectivity (web-a to web-b)...${NC}"
docker exec clab-enterprise-vpn-migration-web-a curl -s http://10.2.20.10 | grep -q "Welcome" && echo -e "${GREEN}✓ Success${NC}" || echo -e "${RED}✗ Failed${NC}"

echo -e "${YELLOW}[6.4] Verifying OSPF neighbors...${NC}"
docker exec clab-enterprise-vpn-migration-router-a1 vtysh -c "show ip ospf neighbor" | grep "Full" && echo -e "${GREEN}✓ OSPF operational${NC}"

echo ""
echo -e "${GREEN}=========================================${NC}"
echo -e "${GREEN}✓ Rollback Complete!${NC}"
echo -e "${GREEN}=========================================${NC}"
echo ""

echo -e "${BLUE}Rollback Summary:${NC}"
echo "  VPN Configuration: Restored to original (old IPs)"
echo "  Old WAN IPs: 203.0.113.10 ↔ 198.51.100.10 (active)"
echo "  New WAN IPs: 192.0.2.10 ↔ 192.0.2.20 (removed)"
echo "  Old Tunnel: gre0 with 172.16.0.1 ↔ 172.16.0.2 (active)"
echo "  New Tunnel: gre1 (removed)"
echo "  Rollback Time: $ROLLBACK_DURATION seconds"
echo ""

if [ $ROLLBACK_DURATION -le 180 ]; then
    echo -e "${GREEN}✓ Rollback completed within target (<3 minutes)${NC}"
else
    echo -e "${YELLOW}⚠ Rollback took longer than target (>3 minutes)${NC}"
fi

echo ""
echo -e "${BLUE}Next steps:${NC}"
echo "  1. Run validation: ${YELLOW}./scripts/validate.sh --pre-migration${NC}"
echo "  2. Review what went wrong with the migration"
echo "  3. Update migration plan to prevent future issues"
echo ""
