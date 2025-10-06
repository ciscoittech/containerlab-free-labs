#!/bin/bash
#############################################################################
# Enterprise VPN Migration Lab - Deployment Script
#############################################################################
#
# Purpose: Deploy the complete 16-container enterprise lab environment
#
# Usage: ./scripts/deploy.sh
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
echo -e "${BLUE}Enterprise VPN Migration Lab - Deployment${NC}"
echo -e "${BLUE}=========================================${NC}"
echo ""

# Check prerequisites
echo -e "${YELLOW}[1/5] Checking prerequisites...${NC}"
if ! command -v containerlab >/dev/null 2>&1; then
    echo -e "${RED}ERROR: containerlab not found${NC}"
    echo "Please install containerlab: https://containerlab.dev/install/"
    exit 1
fi
echo -e "${GREEN}✓ containerlab found${NC}"

if ! command -v docker >/dev/null 2>&1; then
    echo -e "${RED}ERROR: docker not found${NC}"
    echo "Please install Docker: https://docs.docker.com/get-docker/"
    exit 1
fi
echo -e "${GREEN}✓ docker found${NC}"

# Check if lab is already running
echo ""
echo -e "${YELLOW}[2/5] Checking for existing lab...${NC}"
if docker ps --format '{{.Names}}' | grep -q "clab-enterprise-vpn-migration"; then
    echo -e "${YELLOW}⚠ Lab already running. Destroying existing deployment...${NC}"
    containerlab destroy -t topology.clab.yml --cleanup
    sleep 2
fi
echo -e "${GREEN}✓ Ready to deploy${NC}"

# Pull required images
echo ""
echo -e "${YELLOW}[3/5] Pulling container images (this may take a few minutes)...${NC}"
echo -e "${BLUE}ℹ Pulling FRR routers (frrouting/frr:9.1.0)...${NC}"
docker pull frrouting/frr:9.1.0 >/dev/null 2>&1 || echo "Warning: Could not pull FRR image"

echo -e "${BLUE}ℹ Pulling Alpine Linux (alpine:3.18)...${NC}"
docker pull alpine:3.18 >/dev/null 2>&1 || echo "Warning: Could not pull Alpine image"

echo -e "${BLUE}ℹ Pulling VyOS firewall (vyos/vyos:1.4-rolling-202310260023)...${NC}"
docker pull vyos/vyos:1.4-rolling-202310260023 >/dev/null 2>&1 || echo "Warning: Could not pull VyOS image"

echo -e "${BLUE}ℹ Pulling Grafana (grafana/grafana:latest)...${NC}"
docker pull grafana/grafana:latest >/dev/null 2>&1 || echo "Warning: Could not pull Grafana image"

echo -e "${BLUE}ℹ Pulling Netbox (netboxcommunity/netbox:latest)...${NC}"
docker pull netboxcommunity/netbox:latest >/dev/null 2>&1 || echo "Warning: Could not pull Netbox image"

echo -e "${GREEN}✓ Container images ready${NC}"

# Deploy lab topology
echo ""
echo -e "${YELLOW}[4/5] Deploying 16-container topology...${NC}"
echo -e "${BLUE}ℹ This will create:${NC}"
echo "  Site A: isp-a, router-a1, router-a2, firewall-a, web-a, dns-a, ldap-a, monitor-a (8 containers)"
echo "  Site B: isp-b, router-b1, router-b2, firewall-b, web-b, server-b (6 containers)"
echo "  Internet: internet-core, netbox (2 containers)"
echo ""

containerlab deploy -t topology.clab.yml

echo -e "${GREEN}✓ Topology deployed${NC}"

# Wait for services to initialize
echo ""
echo -e "${YELLOW}[5/5] Waiting for services to initialize...${NC}"
echo -e "${BLUE}ℹ Allowing 30 seconds for FRR daemons, nginx, dnsmasq, and Grafana to start${NC}"
sleep 30
echo -e "${GREEN}✓ Services initialized${NC}"

# Display lab summary
echo ""
echo -e "${GREEN}=========================================${NC}"
echo -e "${GREEN}✓ Lab Deployment Complete!${NC}"
echo -e "${GREEN}=========================================${NC}"
echo ""
echo -e "${BLUE}Lab Information:${NC}"
echo "  Total Containers: 16"
echo "  Management Network: 172.20.20.0/24"
echo ""
echo -e "${BLUE}Access Information:${NC}"
echo ""
echo "  Web Services:"
echo "    Web-A (Site A):  http://10.1.20.10"
echo "    Web-B (Site B):  http://10.2.20.10"
echo ""
echo "  Infrastructure Services:"
echo "    DNS-A:           10.1.20.11:53"
echo "    LDAP-A:          10.1.20.12:389"
echo "    Grafana:         http://10.1.20.13:3000"
echo "    Netbox:          http://10.1.20.14:8000"
echo ""
echo "  Router Access (SSH - Recommended):"
echo "    router-a1:      ssh -p 2231 cisco@localhost  # Password: cisco"
echo "    router-a2:      ssh -p 2232 cisco@localhost"
echo "    router-b1:      ssh -p 2233 cisco@localhost"
echo "    router-b2:      ssh -p 2234 cisco@localhost"
echo "    internet-core:  ssh -p 2235 cisco@localhost"
echo ""
echo "  Alternative - Docker Exec Access:"
echo "    router-a1: docker exec -it clab-enterprise-vpn-migration-router-a1 vtysh"
echo "    router-a2: docker exec -it clab-enterprise-vpn-migration-router-a2 vtysh"
echo ""
echo -e "${BLUE}VPN Configuration:${NC}"
echo "  Current VPN Endpoints:"
echo "    Site A: 203.0.113.10 (OLD - to be migrated)"
echo "    Site B: 198.51.100.10 (OLD - to be migrated)"
echo "  GRE Tunnel: 172.16.0.1 ↔ 172.16.0.2"
echo ""
echo -e "${BLUE}Next Steps:${NC}"
echo "  1. Validate baseline:  ${YELLOW}./scripts/validate.sh --pre-migration${NC}"
echo "  2. Review scenario:    ${YELLOW}cat docs/scenario.md${NC}"
echo "  3. Start planning:     ${YELLOW}cat docs/migration-runbook.md${NC}"
echo ""
echo -e "${GREEN}Happy migrating!${NC}"
echo ""
