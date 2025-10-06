# Enterprise VPN Migration Lab

[![Open in GitHub Codespaces](https://github.com/codespaces/badge.svg)](https://codespaces.new?quickstart=1&devcontainer_path=.devcontainer%2Fdevcontainer.json)

A production-grade enterprise network lab simulating a real-world VPN IP migration scenario with minimal downtime requirements. This lab challenges you to plan and execute a critical infrastructure change while maintaining service availability across two geographically separated sites.

## Overview

Simulate a complete enterprise network with 2 sites (16 devices total) connected via site-to-site VPN. Your mission: **migrate VPN endpoints from old ISP IP addresses to new ones with less than 5 minutes of downtime**.

### What You'll Learn

- **Network Discovery & Auditing**: Document real infrastructure with 16 interconnected devices
- **Service Dependency Mapping**: Understand how DNS, LDAP, and web services depend on VPN connectivity
- **Risk Assessment**: Identify single points of failure and plan mitigation strategies
- **Change Management**: Create detailed runbooks for production network changes
- **VPN Technologies**: Configure and migrate GRE tunnels with minimal service disruption
- **Minimal Downtime Strategies**: Execute changes using dual-stack and staged migration techniques

### Topology

**Site A - Chicago HQ** (8 devices):
- `router-a1`: Edge router with VPN endpoint + BGP peering (AS 64512)
- `router-a2`: Core OSPF router connecting to firewall
- `firewall-a`: VyOS zone-based firewall
- Services: `web-a`, `dns-a`, `ldap-a`, `monitor-a` (Grafana)

**Site B - Austin Remote Office** (5 devices):
- `router-b1`: Edge router with VPN endpoint + BGP peering (AS 64513)
- `router-b2`: Core OSPF router connecting to firewall
- `firewall-b`: VyOS zone-based firewall
- Services: `web-b`, `server-b`

**Internet Backbone** (3 devices):
- `internet-core`: ISP backbone router (AS 65000) providing BGP transit
- `isp-a`, `isp-b`: ISP gateway routers
- `netbox`: IPAM and network documentation platform

```
Site A (Chicago)                    Internet Backbone                 Site B (Austin)
┌────────────────────────┐          ┌─────────────────┐          ┌────────────────────────┐
│                        │          │                 │          │                        │
│  ┌───────┐  ┌───────┐ │          │  ┌───────────┐  │          │  ┌───────┐  ┌───────┐ │
│  │web-a  │  │dns-a  │ │          │  │ internet- │  │          │  │web-b  │  │server-│ │
│  │.10    │  │.11    │ │          │  │   core    │  │          │  │.10    │  │b .11  │ │
│  └───┬───┘  └───┬───┘ │          │  │ (AS 65000)│  │          │  └───┬───┘  └───┬───┘ │
│      │          │     │          │  └─┬──────┬──┘  │          │      │          │     │
│  ┌───┴───┐  ┌──┴────┐ │          │    │      │     │          │  ┌───┴──────────┴───┐ │
│  │ldap-a │  │monitor│ │          │ ┌──┴─┐  ┌─┴──┐  │          │  │   firewall-b      │ │
│  │.12    │  │-a .13 │ │          │ │isp-│  │isp-│  │          │  │   10.2.20.2       │ │
│  └───┬───┘  └───┬───┘ │          │ │ a  │  │ b  │  │          │  └────────┬──────────┘ │
│      │          │     │          │ └──┬─┘  └─┬──┘  │          │           │            │
│  ┌───┴──────────┴───┐ │          │    │      │     │          │      ┌────┴────┐       │
│  │   firewall-a     │ │          │    │      │     │          │      │router-b2│       │
│  │   10.1.20.2      │ │          │    │      │     │          │      │10.2.10.1│       │
│  └────────┬─────────┘ │          │    │      │     │          │      └────┬────┘       │
│           │           │          │    │      │     │          │           │            │
│      ┌────┴────┐      │          │    │      │     │          │      ┌────┴────┐       │
│      │router-a2│      │          │    │      │     │          │      │router-b1│       │
│      │10.1.10.1│      │  ┌───────┼────┘      └─────┼───────┐  │      │10.0.34.1│       │
│      └────┬────┘      │  │ OLD VPN              OLD VPN    │  │      └────┬────┘       │
│           │           │  │ 203.0.113.10 ←──GRE──→ 198.51.100.10 │          │           │
│      ┌────┴────┐      │  │                                 │  │      │    │            │
│      │router-a1├──────┼──┘  NEW VPN (Migration Target)    └──┼──────┤    │            │
│      │10.0.12.1│      │     192.0.2.10 ←──GRE──→ 192.0.2.20   │      │    │            │
│      └─────────┘      │                                        │      └────────┘        │
│                       │                                        │                        │
└───────────────────────┘                                        └────────────────────────┘
    10.1.0.0/16                                                      10.2.0.0/16
```

## Quick Start

### Prerequisites

- **Docker** 20.10+ (for running containers)
- **Containerlab** 0.40+ (for network topology orchestration)
- **Resources**: 4GB RAM, 4GB disk space
- **Time**: 2-4 hours for complete lab exercise

### Deploy Lab

```bash
cd network-lab/enterprise-vpn-migration
./scripts/deploy.sh
```

Wait ~30 seconds for all services to initialize (FRR daemons, nginx, dnsmasq, Grafana).

### Validate Baseline

```bash
./scripts/validate.sh --pre-migration
```

**Expected result**: All 16 baseline tests should pass ✅

If any tests fail, troubleshoot before proceeding with the migration exercise.

## Accessing Lab Devices

**Important Note**: FRR containers do NOT include SSH server. This is intentional for security and container best practices.

### Access Router CLI (vtysh)

**Interactive mode** (Cisco-like CLI):
```bash
docker exec -it clab-enterprise-vpn-migration-router-a1 vtysh
```

**Run single command**:
```bash
docker exec clab-enterprise-vpn-migration-router-a1 vtysh -c "show ip bgp summary"
```

**Access bash shell** (for debugging):
```bash
docker exec -it clab-enterprise-vpn-migration-router-a1 bash
```

### Access Other Services

**Alpine Linux containers** (web, dns, ldap servers):
```bash
# Web server
docker exec -it clab-enterprise-vpn-migration-web-a sh

# DNS server
docker exec -it clab-enterprise-vpn-migration-dns-a sh

# LDAP server
docker exec -it clab-enterprise-vpn-migration-ldap-a sh
```

**VyOS Firewall**:
```bash
# Access VyOS configuration mode
docker exec -it clab-enterprise-vpn-migration-firewall-a bash
```

### Common Commands by Device Type

**FRR Routers** (router-a1, router-a2, router-b1, router-b2, internet-core):

| Task | Command |
|------|---------|
| Check BGP status | `docker exec clab-enterprise-vpn-migration-router-a1 vtysh -c "show ip bgp summary"` |
| Check OSPF neighbors | `docker exec clab-enterprise-vpn-migration-router-a1 vtysh -c "show ip ospf neighbor"` |
| View GRE tunnel | `docker exec clab-enterprise-vpn-migration-router-a1 ip tunnel show` |
| Check routing table | `docker exec clab-enterprise-vpn-migration-router-a1 vtysh -c "show ip route"` |
| View configuration | `docker exec clab-enterprise-vpn-migration-router-a1 vtysh -c "show run"` |

**Web Servers** (web-a, web-b):

| Task | Command |
|------|---------|
| Check nginx status | `docker exec clab-enterprise-vpn-migration-web-a ps aux \| grep nginx` |
| Test web service | `docker exec clab-enterprise-vpn-migration-web-a curl -I localhost` |
| View logs | `docker exec clab-enterprise-vpn-migration-web-a cat /var/log/nginx/access.log` |

**DNS Server** (dns-a):

| Task | Command |
|------|---------|
| Test DNS query | `docker exec clab-enterprise-vpn-migration-dns-a nslookup web-a.site-a.local localhost` |
| View dnsmasq config | `docker exec clab-enterprise-vpn-migration-dns-a cat /etc/dnsmasq.conf` |
| Check process | `docker exec clab-enterprise-vpn-migration-dns-a ps aux \| grep dnsmasq` |

**Why no SSH?**
- ✅ Faster container startup (no SSH daemon)
- ✅ Smaller container images (50MB vs 200MB+)
- ✅ More secure (no SSH attack surface)
- ✅ Standard practice for containerized labs
- ✅ Works in GitHub Codespaces

## The Challenge

### Current State

**VPN Configuration**:
- Tunnel endpoints: `203.0.113.10` (Site A) ↔ `198.51.100.10` (Site B)
- Protocol: GRE over Internet (MegaNet Communications ISP)
- Tunnel subnet: `172.16.0.0/30`
- IGP: OSPF Area 0 running over GRE tunnel
- BGP: Both sites peer with internet-core (AS 65000) for redundancy

**Services Running**:
- **Site A**: Web server, DNS (dnsmasq), LDAP directory, Grafana monitoring
- **Site B**: Web server, application server
- **Cross-site dependencies**: Site B users authenticate via Site A LDAP, both sites query Site A DNS

**Business Context**:
- 250 employees depend on inter-site connectivity
- LDAP authentication used for critical applications
- Grafana monitors infrastructure across both sites

### Required Change

**Scenario**: MegaNet Communications is decommissioning their old IP block (`203.0.113.0/24` and `198.51.100.0/24`). You must migrate to new IP addresses:

- **Site A New IP**: `192.0.2.10/30`
- **Site B New IP**: `192.0.2.20/30`

### Constraints

- **Maximum downtime**: 5 minutes (SLA requirement)
- **No data loss**: All existing connections must gracefully fail over
- **Service requirements**:
  - DNS must continue resolving throughout migration
  - Web services must remain accessible with <5 min interruption
  - LDAP authentication cannot break for more than 5 minutes
  - Grafana monitoring should capture migration metrics
- **Rollback plan required**: Must be able to revert in <3 minutes if issues occur

## Student Workflow

### Phase 1: Network Audit (30-45 min)

**Objective**: Understand the current network architecture and document dependencies.

**Tasks**:
1. SSH to all 16 devices and document IP addressing
2. Verify OSPF adjacencies and routing tables
3. Verify BGP sessions and route advertisements
4. Test current VPN connectivity (ping across tunnel)
5. Map service dependencies (which services talk to which)
6. Use Netbox (`http://10.1.20.14:8000`) for IPAM documentation
7. Check Grafana (`http://10.1.20.13:3000`) for baseline traffic patterns

**Access Commands**:
```bash
# Access FRR routers
docker exec -it clab-enterprise-vpn-migration-router-a1 vtysh
docker exec -it clab-enterprise-vpn-migration-router-b1 vtysh

# Access Alpine Linux hosts
docker exec -it clab-enterprise-vpn-migration-web-a sh
docker exec -it clab-enterprise-vpn-migration-web-b sh

# Test connectivity
docker exec -it clab-enterprise-vpn-migration-web-a ping 10.2.20.10
docker exec -it clab-enterprise-vpn-migration-web-a curl http://10.2.20.10
```

**Deliverable**: Network documentation with:
- IP addressing table (all 16 devices)
- Routing protocol adjacencies diagram
- Service dependency map
- Current VPN tunnel configuration

### Phase 2: Risk Assessment (15-30 min)

**Objective**: Identify risks and plan mitigation strategies.

**Tasks**:
1. Identify single points of failure (SPOFs)
2. List all services affected by VPN downtime
3. Define rollback triggers (when to abort migration)
4. Plan validation checkpoints throughout migration
5. Estimate downtime for each migration step

**Key Questions to Answer**:
- What happens if the new GRE tunnel doesn't come up?
- How will you verify each step before proceeding?
- What is the rollback procedure if OSPF doesn't converge?
- How will you minimize downtime during IP address changes?

**Deliverable**: Risk assessment document with:
- SPOF analysis
- Service impact matrix
- Rollback procedure (detailed steps)
- Success criteria for each migration phase

### Phase 3: Change Planning (20-30 min)

**Objective**: Create a detailed, step-by-step migration runbook.

**Tasks**:
1. Break migration into discrete steps
2. Define validation commands for each step
3. Estimate time for each step
4. Identify parallel vs. sequential operations
5. Plan communication to stakeholders

**Migration Strategies to Consider**:
- **Dual-stack approach**: Add new IPs alongside old IPs temporarily
- **Parallel tunnel approach**: Create new GRE tunnel before removing old one
- **OSPF cost manipulation**: Prefer new tunnel while keeping old as backup
- **Staged migration**: Migrate one direction first, then the other

**Template**: Use `docs/migration-runbook.md` as a starting point.

**Deliverable**: Migration runbook with:
- Numbered steps with exact commands
- Validation checkpoints after each step
- Estimated duration for each step
- Total estimated downtime
- Rollback decision points

### Phase 4: Execution (15-30 min)

**Objective**: Execute the migration following your runbook.

**Execution Options**:

**Option 1 - Manual Step-by-Step** (recommended for learning):
```bash
# Follow your runbook, executing each command manually
# Example first step:
docker exec -it clab-enterprise-vpn-migration-router-a1 sh
ip addr add 192.0.2.10/30 dev eth2
ip addr show eth2  # Validate
```

**Option 2 - Guided Migration Script**:
```bash
./scripts/migrate-vpn.sh
# This script will guide you through each step interactively
```

**Option 3 - Automated Migration**:
```bash
./scripts/migrate-vpn.sh --auto
# Fully automated, measures downtime
```

**During Execution**:
- Monitor Grafana for traffic patterns
- Track actual downtime vs. estimated
- Log timestamps for each step
- Test connectivity after each major change
- Be ready to execute rollback if needed

**Deliverable**: Execution log with:
- Actual start/end timestamps for each step
- Validation results at each checkpoint
- Total measured downtime
- Any deviations from plan (and why)

### Phase 5: Post-Migration Validation (20-30 min)

**Objective**: Verify all services are restored and document the change.

**Tasks**:
1. Run automated post-migration tests
2. Verify new VPN IPs are active
3. Confirm old VPN IPs are removed
4. Test all service dependencies
5. Check Grafana for anomalies
6. Update Netbox documentation

**Validation**:
```bash
# Run all post-migration tests
./scripts/validate.sh --post-migration

# Run full test suite
./scripts/validate.sh
```

**Expected Results**:
- Tests 17-22: New WAN IPs configured ✅
- Tests 17-22: Old IPs removed ✅
- Tests 13-16: Services accessible ✅
- Total tests: 22/22 passing

**Deliverable**: Post-migration validation report with:
- All test results (22/22 passing)
- Before/after configuration comparison
- Actual vs. estimated downtime analysis
- Lessons learned
- Updated Netbox documentation

## Validation Tests

The lab includes **22 comprehensive automated tests** organized into 6 categories:

### Pre-Migration Baseline (Tests 1-16)

**Category 1: Infrastructure Health**
- Test 1: All 16 containers running
- Test 2: Network interfaces UP
- Test 3: IP addressing correct
- Test 4: Routing tables populated

**Category 2: Routing Protocols**
- Test 5: OSPF adjacencies FULL
- Test 6: BGP sessions ESTABLISHED
- Test 7: BGP routes advertised
- Test 8: Convergence time (informational)

**Category 3: VPN Tunnel**
- Test 9: GRE tunnel interfaces exist and UP
- Test 10: GRE tunnel IP addressing correct
- Test 11: GRE tunnel connectivity (ping)
- Test 12: IPsec status (optional)

**Category 4: Application Services**
- Test 13: DNS resolution cross-site
- Test 14: Web accessibility (A → B)
- Test 15: Web accessibility (B → A)
- Test 16: LDAP connectivity

### Post-Migration Validation (Tests 17-22)

**Category 5: Migration Validation**
- Test 17: New WAN IPs assigned (192.0.2.x)
- Test 18: Old WAN IPs removed (203.0.113.x, 198.51.100.x)
- Test 19: GRE tunnel using new source/dest IPs
- Test 20: No routing loops (traceroute validation)

**Category 6: Monitoring & Documentation**
- Test 21: Grafana accessible and healthy
- Test 22: Netbox accessible and ready for updates

### Running Tests

```bash
# All tests (22 total)
./scripts/validate.sh

# Pre-migration only (tests 1-16)
./scripts/validate.sh --pre-migration

# Post-migration only (tests 17-22)
./scripts/validate.sh --post-migration

# Quick health check (tests 1, 5, 9, 13)
./scripts/validate.sh --quick
```

## Access Information

### Management Access

All devices are accessible via containerlab container names:

```bash
# FRR Routers (vtysh CLI)
docker exec -it clab-enterprise-vpn-migration-router-a1 vtysh
docker exec -it clab-enterprise-vpn-migration-router-a2 vtysh
docker exec -it clab-enterprise-vpn-migration-router-b1 vtysh
docker exec -it clab-enterprise-vpn-migration-router-b2 vtysh
docker exec -it clab-enterprise-vpn-migration-internet-core vtysh

# Alpine Linux hosts (sh shell)
docker exec -it clab-enterprise-vpn-migration-web-a sh
docker exec -it clab-enterprise-vpn-migration-web-b sh
docker exec -it clab-enterprise-vpn-migration-dns-a sh
docker exec -it clab-enterprise-vpn-migration-ldap-a sh
docker exec -it clab-enterprise-vpn-migration-server-b sh

# ISP Gateways
docker exec -it clab-enterprise-vpn-migration-isp-a sh
docker exec -it clab-enterprise-vpn-migration-isp-b sh

# VyOS Firewalls (VyOS CLI)
docker exec -it clab-enterprise-vpn-migration-firewall-a sh
docker exec -it clab-enterprise-vpn-migration-firewall-b sh
```

### Services

**Web Services**:
- Site A Web: `http://10.1.20.10` (nginx)
- Site B Web: `http://10.2.20.10` (nginx)

**Infrastructure Services**:
- DNS (Site A): `10.1.20.11:53` (dnsmasq)
- LDAP (Site A): `10.1.20.12:389` (OpenLDAP)
- Grafana: `http://10.1.20.13:3000` (monitoring dashboard)
- Netbox: `http://10.1.20.14:8000` (IPAM/documentation)

### Useful Commands

**Check OSPF**:
```bash
docker exec clab-enterprise-vpn-migration-router-a1 vtysh -c "show ip ospf neighbor"
docker exec clab-enterprise-vpn-migration-router-a1 vtysh -c "show ip route ospf"
```

**Check BGP**:
```bash
docker exec clab-enterprise-vpn-migration-router-a1 vtysh -c "show bgp summary"
docker exec clab-enterprise-vpn-migration-router-a1 vtysh -c "show bgp ipv4 unicast"
```

**Check GRE Tunnel**:
```bash
docker exec clab-enterprise-vpn-migration-router-a1 ip tunnel show
docker exec clab-enterprise-vpn-migration-router-a1 ip addr show gre0
docker exec clab-enterprise-vpn-migration-router-a1 ping 172.16.0.2
```

**Test Services**:
```bash
docker exec clab-enterprise-vpn-migration-web-a curl http://10.2.20.10
docker exec clab-enterprise-vpn-migration-web-a nslookup web-b.site-b.local 10.1.20.11
docker exec clab-enterprise-vpn-migration-server-b nc -zv 10.1.20.12 389
```

## Troubleshooting

### Issue: Containers Won't Start

**Symptoms**: `containerlab deploy` fails with container errors

**Possible Causes**:
- Insufficient memory (need 4GB+ available)
- Port conflicts with existing services
- Docker daemon not running

**Solutions**:
```bash
# Check available memory
free -h

# Check Docker status
docker info

# Check for port conflicts
sudo netstat -tulpn | grep :3000

# Destroy any existing lab
containerlab destroy -t topology.clab.yml --cleanup
```

### Issue: OSPF Adjacencies Not Forming

**Symptoms**: Test 5 fails, OSPF neighbors stuck in INIT or 2WAY

**Possible Causes**:
- Interface down on one side
- IP addressing mismatch
- OSPF area mismatch
- MTU mismatch on GRE tunnel

**Solutions**:
```bash
# Check interface status
docker exec clab-enterprise-vpn-migration-router-a1 vtysh -c "show interface brief"

# Check OSPF configuration
docker exec clab-enterprise-vpn-migration-router-a1 vtysh -c "show ip ospf interface"

# Debug OSPF
docker exec clab-enterprise-vpn-migration-router-a1 vtysh -c "debug ospf event"
```

### Issue: BGP Session Not Establishing

**Symptoms**: Test 6 fails, BGP state is Active or Connect

**Possible Causes**:
- TCP connectivity issue (firewall?)
- Incorrect neighbor IP
- AS number mismatch
- BGP not enabled for IPv4

**Solutions**:
```bash
# Check BGP configuration
docker exec clab-enterprise-vpn-migration-router-a1 vtysh -c "show run | section bgp"

# Check TCP connectivity
docker exec clab-enterprise-vpn-migration-router-a1 ping 100.64.0.100

# Debug BGP
docker exec clab-enterprise-vpn-migration-router-a1 vtysh -c "debug bgp keepalives"
```

### Issue: GRE Tunnel No Connectivity

**Symptoms**: Test 11 fails, cannot ping across tunnel

**Possible Causes**:
- GRE tunnel source/dest IPs incorrect
- Routing for tunnel endpoints missing
- Firewall blocking GRE (protocol 47)
- MTU issues

**Solutions**:
```bash
# Verify tunnel configuration
docker exec clab-enterprise-vpn-migration-router-a1 ip tunnel show gre0

# Check if tunnel is UP
docker exec clab-enterprise-vpn-migration-router-a1 ip link show gre0

# Verify tunnel IP addressing
docker exec clab-enterprise-vpn-migration-router-a1 ip addr show gre0

# Test underlying connectivity (WAN IPs)
docker exec clab-enterprise-vpn-migration-router-a1 ping 198.51.100.10

# Check MTU
docker exec clab-enterprise-vpn-migration-router-a1 ip link show gre0 | grep mtu
```

### Issue: Services Not Accessible After Migration

**Symptoms**: Tests 14-16 fail, cannot access web-b from web-a

**Possible Causes**:
- OSPF not converged over new tunnel
- Static routes pointing to old tunnel
- Firewall rules blocking traffic
- Service didn't restart properly

**Solutions**:
```bash
# Check routing table on web-a
docker exec clab-enterprise-vpn-migration-web-a ip route

# Trace route to identify where packets are dropping
docker exec clab-enterprise-vpn-migration-web-a traceroute 10.2.20.10

# Check OSPF routes
docker exec clab-enterprise-vpn-migration-router-a1 vtysh -c "show ip route"

# Verify service is running
docker exec clab-enterprise-vpn-migration-web-b ps aux | grep nginx
```

### Issue: Migration Downtime Exceeds 5 Minutes

**Symptoms**: Migration works but takes >5 minutes, violating SLA

**Possible Causes**:
- Sequential execution when parallel is possible
- Waiting too long for convergence
- Manual command entry too slow
- Not using dual-stack approach

**Solutions**:
- Use dual-stack IP addressing (add new IPs before removing old)
- Create new GRE tunnel in parallel with old tunnel
- Use OSPF cost to prefer new tunnel while old is still up
- Automate with scripts rather than manual entry
- Run `./scripts/migrate-vpn.sh --auto` for optimized execution

See `docs/troubleshooting.md` for more detailed troubleshooting procedures.

## Helper Scripts

### deploy.sh
Deploys the complete 16-container lab environment:
```bash
./scripts/deploy.sh
```

### cleanup.sh
Cleanly destroys the lab and removes all containers:
```bash
./scripts/cleanup.sh
```

### migrate-vpn.sh
Interactive migration assistant (guides through each step):
```bash
./scripts/migrate-vpn.sh           # Interactive mode
./scripts/migrate-vpn.sh --auto    # Automated execution
```

### rollback.sh
Rollback to pre-migration configuration if needed:
```bash
./scripts/rollback.sh
```

### validate.sh
Comprehensive validation test suite:
```bash
./scripts/validate.sh                   # All 22 tests
./scripts/validate.sh --pre-migration   # Tests 1-16
./scripts/validate.sh --post-migration  # Tests 17-22
./scripts/validate.sh --quick           # Critical tests only
```

## Lab Exercises

The lab includes 5 structured exercises in the `exercises/` directory:

1. **Network Audit** (`exercises/01-network-audit.md`)
   - Document IP addressing and routing
   - Map service dependencies
   - Use Netbox for IPAM

2. **Risk Assessment** (`exercises/02-risk-assessment.md`)
   - Identify SPOFs
   - Define rollback triggers
   - Plan validation checkpoints

3. **Change Planning** (`exercises/03-change-planning.md`)
   - Create migration runbook
   - Estimate downtime
   - Define success criteria

4. **Migration Execution** (`exercises/04-migration-execution.md`)
   - Execute planned migration
   - Monitor and log results
   - Measure actual downtime

5. **Post-Validation** (`exercises/05-post-validation.md`)
   - Run validation tests
   - Document lessons learned
   - Update network documentation

## Advanced Challenges

Once you've successfully migrated the VPN, try these advanced scenarios:

### Challenge 1: Zero-Downtime Migration
Can you migrate with **zero downtime** by using:
- Parallel tunnels with OSPF cost manipulation
- Make-before-break approach
- Gradual traffic shift using routing metrics

### Challenge 2: Rollback Under Pressure
Simulate a failed migration:
- New GRE tunnel doesn't come up
- Execute rollback procedure under time pressure
- Target: Restore service in <3 minutes

### Challenge 3: Automation
Create your own migration automation:
- Write Ansible playbook for migration
- Use Python with Netmiko for FRR configuration
- Implement automated validation and rollback

### Challenge 4: Add IPsec Encryption
Enhance security by adding IPsec:
- Configure IPsec tunnel alongside GRE
- Encrypt VPN traffic between sites
- Verify encryption is working with packet capture

### Challenge 5: Monitoring and Alerting
Set up comprehensive monitoring:
- Configure Grafana dashboards for VPN metrics
- Set up alerts for tunnel down events
- Monitor bandwidth utilization across VPN

## Learning Outcomes

After completing this lab, you will be able to:

✅ Plan and execute production network changes with minimal downtime
✅ Design rollback procedures for critical infrastructure changes
✅ Use dual-stack and parallel migration strategies
✅ Configure and troubleshoot GRE tunnels
✅ Integrate OSPF with GRE tunnels for dynamic routing
✅ Configure eBGP between autonomous systems
✅ Validate network changes using automated testing
✅ Document network infrastructure in IPAM systems
✅ Assess risk and create change management procedures
✅ Monitor network services during critical changes

## Technologies Used

- **Containerlab**: Network topology orchestration
- **FRR 9.1.0**: Open-source routing platform (OSPF, BGP)
- **GRE Tunnels**: Site-to-site VPN connectivity
- **VyOS 1.4**: Zone-based firewall
- **Alpine Linux 3.18**: Lightweight service hosts
- **Grafana**: Monitoring and visualization
- **Netbox**: IPAM and network documentation
- **Nginx**: Web server for service testing
- **dnsmasq**: DNS server
- **OpenLDAP**: Directory service

## Resources

### Lab Documentation
- [Scenario Details](docs/scenario.md) - Complete business context and requirements
- [Learning Objectives](docs/objectives.md) - Skills and knowledge gained
- [Technology Decisions](docs/conversion-notes.md) - Design rationale
- [Migration Runbook Template](docs/migration-runbook.md) - Runbook structure
- [Troubleshooting Guide](docs/troubleshooting.md) - Detailed issue resolution

### External Resources
- [FRR Documentation](https://docs.frrouting.org/)
- [Containerlab Documentation](https://containerlab.dev/)
- [OSPF RFC 2328](https://tools.ietf.org/html/rfc2328)
- [BGP RFC 4271](https://tools.ietf.org/html/rfc4271)
- [GRE RFC 2784](https://tools.ietf.org/html/rfc2784)

## License

MIT License - Free for educational use

## Contributing

Contributions welcome! Please submit issues or pull requests for:
- Additional validation tests
- Alternative migration strategies
- Enhanced monitoring dashboards
- Documentation improvements

---

**Ready to start?** Deploy the lab and begin your network audit:

```bash
./scripts/deploy.sh
./scripts/validate.sh --pre-migration
cat docs/scenario.md
```

**Good luck with your migration!** 🚀
