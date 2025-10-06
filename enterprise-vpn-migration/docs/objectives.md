# Enterprise VPN Migration Lab - Learning Objectives

## Overview
This lab simulates a real-world enterprise VPN migration scenario where you must migrate critical VPN endpoints from old IP addresses to new ones with minimal downtime. The lab environment consists of 16 containers across two sites (Site A and Site B) connected via GRE over IPsec tunnels.

## Learning Objectives

### 1. Network Discovery & Infrastructure Auditing
**Objective**: Perform comprehensive network discovery and document the existing infrastructure before making any changes.

**Skills Developed**:
- SSH access to all network devices and servers
- IP address documentation and subnet mapping
- VPN tunnel configuration analysis
- Network topology documentation

**Validation Tests**:
- `test_01`: All 16 containers running and accessible
- `test_02`: Complete IP addressing inventory documented
- `test_03`: VPN tunnel endpoints identified (203.0.113.10 ↔ 198.51.100.10)
- `test_04`: GRE tunnel interface configuration verified

**Success Criteria**:
✅ Student can SSH to all 16 devices
✅ Complete network diagram with IPs documented
✅ VPN configuration files identified and backed up

---

### 2. Service Dependency Mapping
**Objective**: Identify all services that depend on the VPN tunnel and document potential impact of VPN downtime.

**Skills Developed**:
- Application layer troubleshooting
- Service dependency analysis
- Cross-site connectivity testing
- Traffic flow documentation

**Validation Tests**:
- `test_05`: DNS resolution works across VPN (Site A ↔ Site B)
- `test_06`: Web services accessible across sites
- `test_07`: LDAP authentication across VPN verified
- `test_08`: Service failure simulation and impact assessment

**Success Criteria**:
✅ Dependency map showing DNS, Web, LDAP services crossing VPN
✅ Documentation of which services break if VPN is down
✅ Service restoration time estimates documented

---

### 3. Risk Assessment & Change Management Planning
**Objective**: Create a comprehensive migration plan with risk mitigation strategies and rollback procedures.

**Skills Developed**:
- Change management methodology
- Risk assessment and mitigation
- Runbook creation
- Rollback planning

**Validation Tests**:
- `test_09`: Migration runbook created with step-by-step procedure
- `test_10`: Rollback triggers defined (when to abort migration)
- `test_11`: Success criteria documented and testable
- `test_12`: Communication plan for stakeholders

**Success Criteria**:
✅ Detailed runbook with timing estimates for each step
✅ Clear rollback procedure if migration fails
✅ Pre-defined success/failure criteria
✅ Maintenance window duration calculated (<10 minutes target)

---

### 4. VPN IP Migration Execution
**Objective**: Execute the VPN migration from old IPs to new IPs with minimal downtime and zero data loss.

**Skills Developed**:
- GRE tunnel reconfiguration
- IPsec tunnel re-establishment
- Routing protocol convergence
- Live network changes without full outage

**Validation Tests**:
- `test_13`: New GRE tunnel established (192.0.2.10 ↔ 192.0.2.20)
- `test_14`: IPsec tunnel re-negotiated successfully
- `test_15`: Routing tables updated with new VPN routes
- `test_16`: Downtime measured (<5 minutes target)

**Success Criteria**:
✅ VPN migrated from old IPs to new IPs
✅ Total downtime under 5 minutes
✅ No configuration errors requiring rollback
✅ All routing protocols converged

**Migration Steps** (High-Level):
1. Configure new WAN IPs on router-a1 (203.0.113.10 → 192.0.2.10)
2. Configure new WAN IPs on router-b1 (198.51.100.10 → 192.0.2.20)
3. Update GRE tunnel source/destination IPs
4. Update IPsec tunnel peer IPs
5. Restart tunnels and verify connectivity
6. Update BGP peering if needed
7. Remove old IP configurations

---

### 5. Post-Migration Validation & Monitoring
**Objective**: Verify all services are restored and establish ongoing monitoring to ensure migration success.

**Skills Developed**:
- Comprehensive validation testing
- Service health verification
- Monitoring dashboard configuration
- Documentation updates

**Validation Tests**:
- `test_17`: DNS resolution working across new VPN
- `test_18`: Web-A accessible from Site B (10.1.20.10)
- `test_19`: Web-B accessible from Site A (10.2.20.10)
- `test_20`: LDAP authentication functional
- `test_21`: Grafana dashboard shows healthy metrics
- `test_22`: Netbox updated with new IP assignments

**Success Criteria**:
✅ All services restored to pre-migration state
✅ No lingering old VPN routes in routing tables
✅ Monitoring confirms stable tunnel for 30+ minutes
✅ Documentation updated (Netbox, runbook, diagrams)

---

## Lab Completion Criteria

### Minimum Passing Requirements:
- [ ] All 16 containers deployed and accessible
- [ ] Baseline connectivity tests pass (tests 1-8)
- [ ] VPN migration completed successfully (tests 13-16)
- [ ] Post-migration validation passes (tests 17-22)
- [ ] Downtime under 5 minutes
- [ ] Runbook and documentation complete

### Advanced Achievements:
- [ ] Zero-downtime migration using dual-tunnel approach
- [ ] Automated rollback script created
- [ ] Grafana dashboard configured with VPN metrics
- [ ] Complete network documentation in Netbox

---

## Real-World Application

This lab mirrors common enterprise scenarios:

**When You'll Use These Skills**:
- ISP migration projects (changing providers)
- Data center relocations (new WAN IPs)
- VPN endpoint upgrades (new firewall appliances)
- Network consolidation (merging offices)
- Security remediation (IP address changes for threat mitigation)

**Career Value**:
- Network migration planning and execution
- Change management in production environments
- Service continuity during infrastructure changes
- Risk assessment and mitigation strategies
- Documentation and communication skills

---

## Time Estimates

| Phase | Estimated Time |
|-------|---------------|
| Network Discovery & Auditing | 30-45 minutes |
| Service Dependency Mapping | 20-30 minutes |
| Change Planning & Runbook | 30-45 minutes |
| VPN Migration Execution | 15-30 minutes |
| Post-Migration Validation | 20-30 minutes |
| **Total Lab Time** | **2-3 hours** |

---

## Prerequisites

**Required Knowledge**:
- Basic Linux command line
- IP addressing and subnetting
- OSPF routing protocol fundamentals
- GRE tunnel concepts
- IPsec VPN basics

**Recommended Pre-Labs**:
- OSPF Fundamentals Lab
- BGP eBGP Basics Lab
- Linux Network Namespaces Lab
