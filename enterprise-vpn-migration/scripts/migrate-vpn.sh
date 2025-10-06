#!/bin/bash
#############################################################################
# Enterprise VPN Migration Lab - VPN Migration Helper
#############################################################################
#
# Purpose: Guide students through VPN IP migration process
#
# This script provides step-by-step guidance for migrating VPN endpoints
# from old ISP IP addresses to new ones with minimal downtime.
#
# Old VPN IPs: 203.0.113.10 ↔ 198.51.100.10
# New VPN IPs: 192.0.2.10 ↔ 192.0.2.20
#
# Usage: ./scripts/migrate-vpn.sh [--auto]
#
#############################################################################

set -e

# Color codes
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

# Migration mode (manual by default)
AUTO_MODE=false
if [ "$1" = "--auto" ]; then
    AUTO_MODE=true
fi

echo ""
echo -e "${BLUE}=========================================${NC}"
echo -e "${BLUE}VPN Migration Assistant${NC}"
echo -e "${BLUE}=========================================${NC}"
echo ""

echo -e "${YELLOW}⚠ IMPORTANT: VPN IP Migration${NC}"
echo ""
echo "This will migrate VPN endpoints from:"
echo "  OLD: Site A 203.0.113.10 ↔ Site B 198.51.100.10"
echo "  NEW: Site A 192.0.2.10 ↔ Site B 192.0.2.20"
echo ""
echo -e "${RED}Expected Downtime: 3-5 minutes${NC}"
echo ""

if [ "$AUTO_MODE" = false ]; then
    echo -e "${YELLOW}This script will guide you through manual migration steps.${NC}"
    echo "Press Ctrl+C to cancel, or Enter to continue..."
    read
else
    echo -e "${YELLOW}Running in AUTO mode - migration will execute automatically${NC}"
    sleep 2
fi

# Track downtime
DOWNTIME_START=""
DOWNTIME_END=""

# Function to execute command
exec_step() {
    local step_num=$1
    local description=$2
    local container=$3
    shift 3
    local command="$@"

    echo ""
    echo -e "${BLUE}[Step $step_num] $description${NC}"
    echo -e "${YELLOW}Container: $container${NC}"
    echo -e "${YELLOW}Command: $command${NC}"
    echo ""

    if [ "$AUTO_MODE" = false ]; then
        echo "Press Enter to execute (or Ctrl+C to abort)..."
        read
    fi

    docker exec -it "clab-enterprise-vpn-migration-$container" $command
    echo -e "${GREEN}✓ Step $step_num complete${NC}"

    if [ "$AUTO_MODE" = false ]; then
        echo "Press Enter to continue..."
        read
    else
        sleep 2
    fi
}

# Step 1: Pre-migration validation
echo ""
echo -e "${BLUE}========== Phase 1: Pre-Migration Validation ==========${NC}"
echo ""

exec_step "1.1" "Verify old WAN IP on router-a1 (203.0.113.10)" "router-a1" \
    ip addr show eth2

exec_step "1.2" "Verify old WAN IP on router-b1 (198.51.100.10)" "router-b1" \
    ip addr show eth2

exec_step "1.3" "Verify GRE tunnel status on router-a1" "router-a1" \
    ip tunnel show gre0

exec_step "1.4" "Test VPN connectivity (ping across tunnel)" "router-a1" \
    ping -c 3 172.16.0.2

echo ""
echo -e "${GREEN}✓ Pre-migration validation complete${NC}"
echo ""

# Step 2: Configure new WAN IPs (dual-stack approach)
echo ""
echo -e "${BLUE}========== Phase 2: Add New WAN IPs (Dual-Stack) ==========${NC}"
echo ""
echo -e "${YELLOW}ℹ We'll add new IPs alongside old IPs for smooth transition${NC}"
echo ""

# Mark start of downtime window
if [ "$AUTO_MODE" = true ]; then
    DOWNTIME_START=$(date +%s)
fi

exec_step "2.1" "Add new WAN IP to router-a1 (192.0.2.10)" "router-a1" \
    ip addr add 192.0.2.10/30 dev eth2

exec_step "2.2" "Add new WAN IP to router-b1 (192.0.2.20)" "router-b1" \
    ip addr add 192.0.2.20/30 dev eth2

exec_step "2.3" "Verify dual-stack on router-a1" "router-a1" \
    ip addr show eth2

exec_step "2.4" "Test new WAN connectivity (ping new gateway from router-a1)" "router-a1" \
    ping -c 3 192.0.2.9

echo ""
echo -e "${GREEN}✓ New WAN IPs added (dual-stack mode)${NC}"
echo ""

# Step 3: Create new GRE tunnel
echo ""
echo -e "${BLUE}========== Phase 3: Create New GRE Tunnel ==========${NC}"
echo ""
echo -e "${YELLOW}ℹ Creating new GRE tunnel using new WAN IPs${NC}"
echo ""

exec_step "3.1" "Create new GRE tunnel (gre1) on router-a1" "router-a1" \
    ip tunnel add gre1 mode gre remote 192.0.2.20 local 192.0.2.10 ttl 255

exec_step "3.2" "Assign IP to new tunnel on router-a1" "router-a1" \
    sh -c "ip addr add 172.16.1.1/30 dev gre1 && ip link set gre1 up"

exec_step "3.3" "Create new GRE tunnel (gre1) on router-b1" "router-b1" \
    ip tunnel add gre1 mode gre remote 192.0.2.10 local 192.0.2.20 ttl 255

exec_step "3.4" "Assign IP to new tunnel on router-b1" "router-b1" \
    sh -c "ip addr add 172.16.1.2/30 dev gre1 && ip link set gre1 up"

exec_step "3.5" "Test new tunnel connectivity" "router-a1" \
    ping -c 3 172.16.1.2

echo ""
echo -e "${GREEN}✓ New GRE tunnel operational${NC}"
echo ""

# Step 4: Update OSPF to use new tunnel
echo ""
echo -e "${BLUE}========== Phase 4: Migrate OSPF to New Tunnel ==========${NC}"
echo ""

exec_step "4.1" "Add gre1 to OSPF on router-a1" "router-a1" \
    vtysh -c "conf t" -c "interface gre1" -c "ip ospf area 0" -c "ip ospf network point-to-point" -c "end"

exec_step "4.2" "Add gre1 to OSPF on router-b1" "router-b1" \
    vtysh -c "conf t" -c "interface gre1" -c "ip ospf area 0" -c "ip ospf network point-to-point" -c "end"

exec_step "4.3" "Verify OSPF neighbors on router-a1" "router-a1" \
    vtysh -c "show ip ospf neighbor"

echo ""
echo -e "${YELLOW}ℹ Wait 10 seconds for OSPF convergence...${NC}"
sleep 10
echo ""

exec_step "4.4" "Verify routes on router-a1" "router-a1" \
    vtysh -c "show ip route"

echo ""
echo -e "${GREEN}✓ OSPF migrated to new tunnel${NC}"
echo ""

# Step 5: Remove old tunnel
echo ""
echo -e "${BLUE}========== Phase 5: Remove Old Tunnel ==========${NC}"
echo ""

exec_step "5.1" "Remove old tunnel from OSPF on router-a1" "router-a1" \
    vtysh -c "conf t" -c "interface gre0" -c "no ip ospf area 0" -c "end"

exec_step "5.2" "Remove old tunnel from OSPF on router-b1" "router-b1" \
    vtysh -c "conf t" -c "interface gre0" -c "no ip ospf area 0" -c "end"

exec_step "5.3" "Shut down old tunnel on router-a1" "router-a1" \
    ip link set gre0 down

exec_step "5.4" "Shut down old tunnel on router-b1" "router-b1" \
    ip link set gre0 down

exec_step "5.5" "Delete old tunnel on router-a1" "router-a1" \
    ip tunnel del gre0

exec_step "5.6" "Delete old tunnel on router-b1" "router-b1" \
    ip tunnel del gre0

echo ""
echo -e "${GREEN}✓ Old tunnel removed${NC}"
echo ""

# Step 6: Remove old WAN IPs
echo ""
echo -e "${BLUE}========== Phase 6: Remove Old WAN IPs ==========${NC}"
echo ""

exec_step "6.1" "Remove old WAN IP from router-a1" "router-a1" \
    ip addr del 203.0.113.10/30 dev eth2

exec_step "6.2" "Remove old WAN IP from router-b1" "router-b1" \
    ip addr del 198.51.100.10/30 dev eth2

exec_step "6.3" "Verify final WAN config on router-a1" "router-a1" \
    ip addr show eth2

exec_step "6.4" "Verify final WAN config on router-b1" "router-b1" \
    ip addr show eth2

# Mark end of downtime window
if [ "$AUTO_MODE" = true ]; then
    DOWNTIME_END=$(date +%s)
    DOWNTIME_DURATION=$((DOWNTIME_END - DOWNTIME_START))
    echo ""
    echo -e "${GREEN}Total Downtime: $DOWNTIME_DURATION seconds${NC}"
fi

echo ""
echo -e "${GREEN}✓ Old WAN IPs removed${NC}"
echo ""

# Step 7: Final validation
echo ""
echo -e "${BLUE}========== Phase 7: Post-Migration Validation ==========${NC}"
echo ""

exec_step "7.1" "Test end-to-end connectivity (web-a to web-b)" "web-a" \
    curl -s http://10.2.20.10

exec_step "7.2" "Verify OSPF neighbors" "router-a1" \
    vtysh -c "show ip ospf neighbor"

exec_step "7.3" "Verify BGP sessions" "router-a1" \
    vtysh -c "show bgp summary"

exec_step "7.4" "Trace route to Site B" "web-a" \
    traceroute -m 10 10.2.20.10

echo ""
echo -e "${GREEN}=========================================${NC}"
echo -e "${GREEN}✓ VPN Migration Complete!${NC}"
echo -e "${GREEN}=========================================${NC}"
echo ""

if [ "$AUTO_MODE" = true ] && [ -n "$DOWNTIME_DURATION" ]; then
    echo -e "${BLUE}Migration Summary:${NC}"
    echo "  Old VPN: 203.0.113.10 ↔ 198.51.100.10 (removed)"
    echo "  New VPN: 192.0.2.10 ↔ 192.0.2.20 (active)"
    echo "  Downtime: $DOWNTIME_DURATION seconds"
    echo ""

    if [ $DOWNTIME_DURATION -le 300 ]; then
        echo -e "${GREEN}✓ Downtime within SLA (<5 minutes)${NC}"
    else
        echo -e "${RED}✗ Downtime exceeded SLA (>5 minutes)${NC}"
    fi
fi

echo ""
echo -e "${BLUE}Next steps:${NC}"
echo "  1. Run full validation: ${YELLOW}./scripts/validate.sh${NC}"
echo "  2. Update documentation in Netbox"
echo "  3. Notify stakeholders of completion"
echo ""
