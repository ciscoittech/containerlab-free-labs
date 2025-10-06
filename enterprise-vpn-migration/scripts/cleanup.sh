#!/bin/bash
#############################################################################
# Enterprise VPN Migration Lab - Cleanup Script
#############################################################################
#
# Purpose: Cleanly destroy the lab environment
#
# Usage: ./scripts/cleanup.sh
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
echo -e "${BLUE}=========================================${NC}"
echo -e "${BLUE}Enterprise VPN Migration Lab - Cleanup${NC}"
echo -e "${BLUE}=========================================${NC}"
echo ""

# Confirm cleanup
echo -e "${YELLOW}⚠ This will destroy all lab containers and cleanup resources.${NC}"
echo -e "${YELLOW}⚠ Any unsaved configurations will be lost.${NC}"
echo ""
read -p "Continue? [y/N] " -n 1 -r
echo
if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    echo -e "${BLUE}ℹ Cleanup cancelled.${NC}"
    exit 0
fi

# Check if lab is running
echo ""
echo -e "${YELLOW}[1/2] Checking for running lab...${NC}"
if docker ps --format '{{.Names}}' | grep -q "clab-enterprise-vpn-migration"; then
    echo -e "${BLUE}ℹ Found running lab containers${NC}"

    # List running containers
    echo -e "${BLUE}ℹ Running containers:${NC}"
    docker ps --format 'table {{.Names}}\t{{.Status}}' | grep "clab-enterprise-vpn-migration" | sed 's/^/  /'
else
    echo -e "${BLUE}ℹ No running lab containers found${NC}"
fi

# Destroy lab
echo ""
echo -e "${YELLOW}[2/2] Destroying lab topology...${NC}"
if [ -f "topology.clab.yml" ]; then
    containerlab destroy -t topology.clab.yml --cleanup
    echo -e "${GREEN}✓ Lab destroyed successfully${NC}"
else
    echo -e "${RED}ERROR: topology.clab.yml not found${NC}"
    echo "Are you in the lab directory?"
    exit 1
fi

# Final status
echo ""
echo -e "${GREEN}=========================================${NC}"
echo -e "${GREEN}✓ Cleanup Complete!${NC}"
echo -e "${GREEN}=========================================${NC}"
echo ""
echo -e "${BLUE}ℹ All lab containers have been removed${NC}"
echo -e "${BLUE}ℹ Network resources have been cleaned up${NC}"
echo ""
echo "To redeploy the lab, run: ${YELLOW}./scripts/deploy.sh${NC}"
echo ""
