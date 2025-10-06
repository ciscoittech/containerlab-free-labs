# Exercise 1: Network Audit and Discovery

## Objective

Document the complete enterprise network architecture including all 16 devices, routing protocols, service dependencies, and current VPN configuration.

## Prerequisites

- Lab deployed successfully (`./scripts/deploy.sh` completed)
- All 16 containers running
- Baseline validation tests passing (`./scripts/validate.sh --pre-migration`)

## Time Estimate

30-45 minutes

## Learning Outcomes

After completing this exercise, you will be able to:
- Systematically document network infrastructure
- Map routing protocol adjacencies
- Identify service dependencies across sites
- Use IPAM tools (Netbox) for network documentation
- Create network diagrams from live infrastructure

---

## Task 1: Document IP Addressing (10 minutes)

### Instructions

Create a comprehensive IP addressing table for all 16 devices.

**Required Information for Each Device**:
- Device name
- Device role (edge router, core router, firewall, service host)
- All interface names
- IP addresses on each interface
- Gateway IP (for end hosts)

### Commands to Use

```bash
# For FRR routers
docker exec -it clab-enterprise-vpn-migration-router-a1 vtysh -c "show interface brief"
docker exec -it clab-enterprise-vpn-migration-router-a1 ip addr show

# For Alpine Linux hosts
docker exec -it clab-enterprise-vpn-migration-web-a ip addr show
docker exec -it clab-enterprise-vpn-migration-web-a ip route
```

### Deliverable

Create a table in the format below:

| Device | Role | Interface | IP Address | Subnet Mask | Gateway | Notes |
|--------|------|-----------|------------|-------------|---------|-------|
| router-a1 | Edge Router | eth1 | 10.0.12.1 | /30 | N/A | OSPF to router-a2 |
| router-a1 | Edge Router | eth2 | 203.0.113.10 | /30 | 203.0.113.9 | WAN (old) |
| router-a1 | Edge Router | eth3 | 100.64.0.10 | /24 | N/A | BGP peering |
| router-a1 | Edge Router | gre0 | 172.16.0.1 | /30 | N/A | VPN tunnel |
| ... | ... | ... | ... | ... | ... | ... |

**Minimum**: Document all 4 FRR routers, all service hosts (web-a, web-b, dns-a, ldap-a, server-b)

---

## Task 2: Map Routing Protocol Adjacencies (10 minutes)

### Instructions

Document all OSPF and BGP adjacencies, including neighbor IPs, router IDs, and adjacency states.

### OSPF Adjacencies to Document

**Site A OSPF**:
- router-a1 ↔ router-a2
- router-a1 ↔ router-b1 (via gre0 tunnel)

**Site B OSPF**:
- router-b1 ↔ router-b2

### Commands to Use

```bash
# OSPF neighbors
docker exec clab-enterprise-vpn-migration-router-a1 vtysh -c "show ip ospf neighbor"
docker exec clab-enterprise-vpn-migration-router-a1 vtysh -c "show ip ospf interface"

# OSPF database
docker exec clab-enterprise-vpn-migration-router-a1 vtysh -c "show ip ospf database"
```

### Deliverable

**OSPF Adjacency Table**:

| Router | Interface | Neighbor ID | Neighbor IP | State | Dead Time | Area |
|--------|-----------|-------------|-------------|-------|-----------|------|
| router-a1 | eth1 | 10.0.12.2 | 10.0.12.2 | Full | 30s | 0 |
| router-a1 | gre0 | 10.0.34.1 | 172.16.0.2 | Full | 30s | 0 |
| ... | ... | ... | ... | ... | ... | ... |

**BGP Peering Table**:

| Router | Local AS | Neighbor IP | Remote AS | State | Prefixes Received |
|--------|----------|-------------|-----------|-------|-------------------|
| router-a1 | 64512 | 100.64.0.100 | 65000 | Established | 2 |
| router-b1 | 64513 | 100.64.0.101 | 65000 | Established | 2 |
| internet-core | 65000 | 100.64.0.10 | 64512 | Established | 1 |
| internet-core | 65000 | 100.64.0.20 | 64513 | Established | 1 |

---

## Task 3: Verify Routing Tables (10 minutes)

### Instructions

Document the routing tables on key routers to understand traffic flow.

**Focus on**:
- Default routes
- Inter-site routes (Site A → Site B and vice versa)
- Route sources (OSPF, BGP, static, connected)

### Commands to Use

```bash
# View routing table
docker exec clab-enterprise-vpn-migration-router-a1 vtysh -c "show ip route"

# Filter specific routes
docker exec clab-enterprise-vpn-migration-router-a1 vtysh -c "show ip route 10.2.0.0/16"
docker exec clab-enterprise-vpn-migration-router-a1 vtysh -c "show ip route ospf"
docker exec clab-enterprise-vpn-migration-router-a1 vtysh -c "show ip route bgp"
```

### Deliverable

**Key Routes Table**:

| Router | Destination | Next Hop | Interface | Protocol | Metric | Notes |
|--------|-------------|----------|-----------|----------|--------|-------|
| router-a1 | 0.0.0.0/0 | 203.0.113.9 | eth2 | Static | 1 | Default via ISP |
| router-a1 | 10.2.0.0/16 | 172.16.0.2 | gre0 | OSPF | 110 | To Site B via VPN |
| router-a2 | 10.1.20.0/24 | 10.1.10.2 | eth2 | Static | 1 | To firewall-a |
| ... | ... | ... | ... | ... | ... | ... |

**Questions to Answer**:
1. How does traffic from Site A reach Site B?
2. What happens if the GRE tunnel goes down?
3. Is there a backup path via BGP?

---

## Task 4: Map Service Dependencies (15 minutes)

### Instructions

Identify which services depend on which other services, especially across sites.

**Services to Test**:
- Web-A (10.1.20.10)
- Web-B (10.2.20.10)
- DNS-A (10.1.20.11)
- LDAP-A (10.1.20.12)
- Grafana (10.1.20.13)
- Netbox (10.1.20.14)

### Commands to Use

```bash
# Test web service access
docker exec clab-enterprise-vpn-migration-web-a curl -s http://10.2.20.10
docker exec clab-enterprise-vpn-migration-web-b curl -s http://10.1.20.10

# Test DNS resolution
docker exec clab-enterprise-vpn-migration-web-a nslookup web-b.site-b.local 10.1.20.11
docker exec clab-enterprise-vpn-migration-web-b nslookup web-a.site-a.local 10.1.20.11

# Test LDAP connectivity
docker exec clab-enterprise-vpn-migration-server-b nc -zv 10.1.20.12 389

# Trace paths
docker exec clab-enterprise-vpn-migration-web-a traceroute 10.2.20.10
docker exec clab-enterprise-vpn-migration-web-b traceroute 10.1.20.10
```

### Deliverable

**Service Dependency Diagram**:

```
Site A                          VPN                          Site B
┌─────────────────────┐    ┌──────────┐    ┌─────────────────────┐
│ web-a (10.1.20.10)  │    │   GRE    │    │ web-b (10.2.20.10)  │
│   ▲                 │    │  tunnel  │    │                     │
│   │ depends on      │    └──────────┘    │                     │
│   │                 │                     │                     │
│ dns-a (10.1.20.11)  │◄────────────────────┼─ server-b queries  │
│   ▲                 │                     │                     │
│   │                 │                     │                     │
│ ldap-a (10.1.20.12) │◄────────────────────┼─ server-b auth     │
└─────────────────────┘                     └─────────────────────┘
```

**Service Dependency Matrix**:

| Service | Located | Accessed From | Protocol | Port | VPN Required? |
|---------|---------|---------------|----------|------|---------------|
| web-a | Site A | Site B | HTTP | 80 | Yes |
| web-b | Site B | Site A | HTTP | 80 | Yes |
| dns-a | Site A | Site B | DNS | 53 | Yes |
| ldap-a | Site A | Site B | LDAP | 389 | Yes |
| grafana | Site A | Both | HTTP | 3000 | Partial |

**Critical Finding**: How many services will be affected if VPN goes down?

---

## Task 5: Document Current VPN Configuration (10 minutes)

### Instructions

Record the exact current VPN configuration that will be migrated.

### Commands to Use

```bash
# GRE tunnel configuration
docker exec clab-enterprise-vpn-migration-router-a1 ip tunnel show gre0
docker exec clab-enterprise-vpn-migration-router-b1 ip tunnel show gre0

# Tunnel interface details
docker exec clab-enterprise-vpn-migration-router-a1 ip addr show gre0
docker exec clab-enterprise-vpn-migration-router-a1 ip link show gre0

# OSPF configuration on tunnel
docker exec clab-enterprise-vpn-migration-router-a1 vtysh -c "show ip ospf interface gre0"

# Test tunnel connectivity
docker exec clab-enterprise-vpn-migration-router-a1 ping -c 5 172.16.0.2
```

### Deliverable

**Current VPN Configuration Document**:

```
VPN Configuration - Pre-Migration State
========================================

Site A (router-a1):
  WAN Interface: eth2
  WAN IP: 203.0.113.10/30
  WAN Gateway: 203.0.113.9
  GRE Tunnel: gre0
    - Mode: GRE
    - Local IP: 203.0.113.10
    - Remote IP: 198.51.100.10
    - Tunnel IP: 172.16.0.1/30
    - MTU: 1400
    - Status: UP
  OSPF on Tunnel:
    - Area: 0
    - Network Type: point-to-point
    - Cost: 100
    - Hello Interval: 5s
    - Dead Interval: 15s

Site B (router-b1):
  WAN Interface: eth2
  WAN IP: 198.51.100.10/30
  WAN Gateway: 198.51.100.9
  GRE Tunnel: gre0
    - Mode: GRE
    - Local IP: 198.51.100.10
    - Remote IP: 203.0.113.10
    - Tunnel IP: 172.16.0.2/30
    - MTU: 1400
    - Status: UP
  OSPF on Tunnel:
    - Area: 0
    - Network Type: point-to-point
    - Cost: 100
    - Hello Interval: 5s
    - Dead Interval: 15s

Tunnel Connectivity Test:
  - Ping 172.16.0.1 → 172.16.0.2: 5/5 packets, 0% loss, avg RTT: 0.5ms
  - Ping 172.16.0.2 → 172.16.0.1: 5/5 packets, 0% loss, avg RTT: 0.5ms
```

---

## Task 6: Use Netbox for IPAM Documentation (Optional, 10 minutes)

### Instructions

Access the Netbox IPAM system and document the network infrastructure.

**Note**: Netbox may take a few minutes to fully initialize after lab deployment.

### Access

- **URL**: `http://10.1.20.14:8000` (from any lab container)
- **From Host**: Port may be mapped differently; check containerlab output

### Actions

1. Access Netbox web interface
2. Create Site objects for "Site A - Chicago" and "Site B - Austin"
3. Add device entries for router-a1, router-b1, router-a2, router-b2
4. Document IP addresses for each device
5. Create prefix entries for 10.1.0.0/16, 10.2.0.0/16, 172.16.0.0/30

**If Netbox is not accessible**, document manually in spreadsheet format.

---

## Verification

Before moving to the next exercise, verify you have completed:

- [ ] IP addressing table for all 16 devices (minimum: 4 routers + 5 service hosts)
- [ ] OSPF adjacency table (minimum: 3 adjacencies documented)
- [ ] BGP peering table (4 sessions documented)
- [ ] Key routes table showing inter-site routing
- [ ] Service dependency diagram or matrix
- [ ] Complete current VPN configuration document
- [ ] Answers to critical questions about traffic flow

---

## Next Exercise

Proceed to **Exercise 2: Risk Assessment** (`exercises/02-risk-assessment.md`)

---

## Reference

- [Lab README](../README.md)
- [Scenario Details](../docs/scenario.md)
- [FRR Documentation](https://docs.frrouting.org/)
