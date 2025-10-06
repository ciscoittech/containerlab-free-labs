# VPN Migration Runbook Template

**Change ID**: VPN-MIG-2024-001
**Change Owner**: [Your Name]
**Date**: [YYYY-MM-DD]
**Estimated Duration**: 15-30 minutes
**Maximum Allowable Downtime**: 5 minutes

---

## Executive Summary

**Purpose**: Migrate VPN endpoints from old ISP IP addresses to new IP block

**Old Configuration**:
- Site A VPN Endpoint: `203.0.113.10/30`
- Site B VPN Endpoint: `198.51.100.10/30`
- GRE Tunnel: `172.16.0.1` ↔ `172.16.0.2`

**New Configuration**:
- Site A VPN Endpoint: `192.0.2.10/30`
- Site B VPN Endpoint: `192.0.2.20/30`
- GRE Tunnel: `172.16.0.1` ↔ `172.16.0.2` (tunnel IPs unchanged)

**Reason for Change**: ISP (MegaNet Communications) is decommissioning old IP block

**Services Affected**:
- Site-to-site VPN connectivity
- Inter-site web services
- LDAP authentication (Site A → Site B)
- DNS resolution across sites
- Grafana monitoring

---

## Pre-Migration Checklist

- [ ] All baseline validation tests passing (`./scripts/validate.sh --pre-migration`)
- [ ] Service dependency map created and reviewed
- [ ] Rollback procedure documented and tested
- [ ] Change window scheduled: [Date/Time]
- [ ] Stakeholders notified (email sent, Slack announcement)
- [ ] Grafana dashboards ready for monitoring
- [ ] Netbox documentation reviewed
- [ ] Backup configurations saved
- [ ] Team member assigned as rollback trigger authority
- [ ] Communication plan prepared for downtime alerts

---

## Migration Strategy

**Approach**: Dual-stack parallel tunnel migration

**Key Principles**:
1. Add new IPs before removing old IPs (dual-stack)
2. Create new GRE tunnel in parallel with old tunnel
3. Migrate OSPF to new tunnel before removing old
4. Verify at each step before proceeding
5. Keep old tunnel operational until new is fully verified

**Downtime Window**:
- **Start**: When old tunnel is removed from OSPF
- **End**: When new tunnel is fully operational in OSPF
- **Estimated**: 2-3 minutes

---

## Migration Steps

### Phase 1: Pre-Migration Validation (5 minutes)

#### Step 1.1: Verify Old WAN IP on Router-A1
**Estimated Time**: 30 seconds
**Rollback Time**: N/A

**Commands**:
```bash
docker exec -it clab-enterprise-vpn-migration-router-a1 ip addr show eth2
```

**Expected Output**:
```
inet 203.0.113.10/30 scope global eth2
```

**Validation**: Old WAN IP `203.0.113.10/30` is present
**Rollback Trigger**: N/A (read-only check)

---

#### Step 1.2: Verify Old WAN IP on Router-B1
**Estimated Time**: 30 seconds
**Rollback Time**: N/A

**Commands**:
```bash
docker exec -it clab-enterprise-vpn-migration-router-b1 ip addr show eth2
```

**Expected Output**:
```
inet 198.51.100.10/30 scope global eth2
```

**Validation**: Old WAN IP `198.51.100.10/30` is present
**Rollback Trigger**: N/A (read-only check)

---

#### Step 1.3: Verify Current GRE Tunnel
**Estimated Time**: 30 seconds
**Rollback Time**: N/A

**Commands**:
```bash
docker exec -it clab-enterprise-vpn-migration-router-a1 ip tunnel show gre0
docker exec -it clab-enterprise-vpn-migration-router-a1 ping -c 3 172.16.0.2
```

**Expected Output**:
- Tunnel exists with `remote 198.51.100.10 local 203.0.113.10`
- Ping succeeds (3/3 packets received)

**Validation**: GRE tunnel operational
**Rollback Trigger**: If tunnel not working, investigate before migration

---

#### Step 1.4: Test End-to-End Connectivity
**Estimated Time**: 1 minute
**Rollback Time**: N/A

**Commands**:
```bash
docker exec -it clab-enterprise-vpn-migration-web-a curl -s http://10.2.20.10
docker exec -it clab-enterprise-vpn-migration-web-b curl -s http://10.1.20.10
```

**Expected Output**: Both commands return web page HTML

**Validation**: Services accessible across VPN
**Rollback Trigger**: If services not accessible, fix before migration

---

### Phase 2: Add New WAN IPs (Dual-Stack) (3 minutes)

**Downtime Impact**: NONE (adding IPs is non-disruptive)

---

#### Step 2.1: Add New WAN IP to Router-A1
**Estimated Time**: 1 minute
**Rollback Time**: 30 seconds

**Commands**:
```bash
docker exec -it clab-enterprise-vpn-migration-router-a1 ip addr add 192.0.2.10/30 dev eth2
docker exec -it clab-enterprise-vpn-migration-router-a1 ip addr show eth2
```

**Expected Output**:
```
inet 203.0.113.10/30 scope global eth2
inet 192.0.2.10/30 scope global secondary eth2
```

**Validation**: Both old and new IPs present (dual-stack)

**Rollback Trigger**: Cannot add new IP (likely conflict)
**Rollback Command**:
```bash
docker exec -it clab-enterprise-vpn-migration-router-a1 ip addr del 192.0.2.10/30 dev eth2
```

---

#### Step 2.2: Add New WAN IP to Router-B1
**Estimated Time**: 1 minute
**Rollback Time**: 30 seconds

**Commands**:
```bash
docker exec -it clab-enterprise-vpn-migration-router-b1 ip addr add 192.0.2.20/30 dev eth2
docker exec -it clab-enterprise-vpn-migration-router-b1 ip addr show eth2
```

**Expected Output**:
```
inet 198.51.100.10/30 scope global eth2
inet 192.0.2.20/30 scope global secondary eth2
```

**Validation**: Both old and new IPs present (dual-stack)

**Rollback Trigger**: Cannot add new IP
**Rollback Command**:
```bash
docker exec -it clab-enterprise-vpn-migration-router-b1 ip addr del 192.0.2.20/30 dev eth2
```

---

#### Step 2.3: Test New WAN Connectivity
**Estimated Time**: 1 minute
**Rollback Time**: N/A

**Commands**:
```bash
docker exec -it clab-enterprise-vpn-migration-router-a1 ping -c 3 -I 192.0.2.10 192.0.2.9
docker exec -it clab-enterprise-vpn-migration-router-b1 ping -c 3 -I 192.0.2.20 192.0.2.19
```

**Expected Output**: Pings to new ISP gateways succeed

**Validation**: New WAN IPs have basic connectivity

**Rollback Trigger**: Cannot ping new gateway (ISP issue, abort migration)
**Rollback Actions**:
1. Remove new IPs
2. Notify ISP of connectivity issue
3. Reschedule migration

---

### Phase 3: Create New GRE Tunnel (3 minutes)

**Downtime Impact**: NONE (creating new tunnel doesn't affect old tunnel)

---

#### Step 3.1: Create GRE1 Tunnel on Router-A1
**Estimated Time**: 1 minute
**Rollback Time**: 30 seconds

**Commands**:
```bash
docker exec -it clab-enterprise-vpn-migration-router-a1 ip tunnel add gre1 mode gre remote 192.0.2.20 local 192.0.2.10 ttl 255
docker exec -it clab-enterprise-vpn-migration-router-a1 ip addr add 172.16.1.1/30 dev gre1
docker exec -it clab-enterprise-vpn-migration-router-a1 ip link set gre1 up
docker exec -it clab-enterprise-vpn-migration-router-a1 ip link set gre1 mtu 1400
```

**Expected Output**: No errors

**Validation**: New tunnel interface exists and is UP
```bash
docker exec -it clab-enterprise-vpn-migration-router-a1 ip link show gre1
```

**Rollback Trigger**: Cannot create tunnel
**Rollback Command**:
```bash
docker exec -it clab-enterprise-vpn-migration-router-a1 ip link set gre1 down
docker exec -it clab-enterprise-vpn-migration-router-a1 ip tunnel del gre1
```

---

#### Step 3.2: Create GRE1 Tunnel on Router-B1
**Estimated Time**: 1 minute
**Rollback Time**: 30 seconds

**Commands**:
```bash
docker exec -it clab-enterprise-vpn-migration-router-b1 ip tunnel add gre1 mode gre remote 192.0.2.10 local 192.0.2.20 ttl 255
docker exec -it clab-enterprise-vpn-migration-router-b1 ip addr add 172.16.1.2/30 dev gre1
docker exec -it clab-enterprise-vpn-migration-router-b1 ip link set gre1 up
docker exec -it clab-enterprise-vpn-migration-router-b1 ip link set gre1 mtu 1400
```

**Expected Output**: No errors

**Validation**: New tunnel interface exists and is UP

**Rollback Trigger**: Cannot create tunnel
**Rollback Command**:
```bash
docker exec -it clab-enterprise-vpn-migration-router-b1 ip link set gre1 down
docker exec -it clab-enterprise-vpn-migration-router-b1 ip tunnel del gre1
```

---

#### Step 3.3: Test New Tunnel Connectivity
**Estimated Time**: 1 minute
**Rollback Time**: N/A

**Commands**:
```bash
docker exec -it clab-enterprise-vpn-migration-router-a1 ping -c 5 172.16.1.2
docker exec -it clab-enterprise-vpn-migration-router-b1 ping -c 5 172.16.1.1
```

**Expected Output**: All pings succeed (10/10 packets)

**Validation**: New tunnel has bidirectional connectivity

**Rollback Trigger**: Cannot ping across new tunnel (critical failure)
**Rollback Actions**:
1. Delete new tunnels (gre1)
2. Remove new WAN IPs
3. Investigate root cause
4. Reschedule migration

---

### Phase 4: Migrate OSPF to New Tunnel (4 minutes)

**⚠️ DOWNTIME WINDOW STARTS HERE ⚠️**
**Start Time**: __________ (record actual time)

---

#### Step 4.1: Add GRE1 to OSPF on Router-A1
**Estimated Time**: 1 minute
**Rollback Time**: 30 seconds

**Commands**:
```bash
docker exec -it clab-enterprise-vpn-migration-router-a1 vtysh -c "conf t" -c "interface gre1" -c "ip ospf area 0" -c "ip ospf network point-to-point" -c "ip ospf cost 50" -c "end"
```

**Expected Output**: `Configuration saved`

**Validation**: GRE1 appears in OSPF interface list with cost 50 (preferred over gre0 cost 100)
```bash
docker exec -it clab-enterprise-vpn-migration-router-a1 vtysh -c "show ip ospf interface gre1"
```

**Rollback Trigger**: Cannot add to OSPF
**Rollback Command**:
```bash
docker exec -it clab-enterprise-vpn-migration-router-a1 vtysh -c "conf t" -c "interface gre1" -c "no ip ospf area 0" -c "end"
```

---

#### Step 4.2: Add GRE1 to OSPF on Router-B1
**Estimated Time**: 1 minute
**Rollback Time**: 30 seconds

**Commands**:
```bash
docker exec -it clab-enterprise-vpn-migration-router-b1 vtysh -c "conf t" -c "interface gre1" -c "ip ospf area 0" -c "ip ospf network point-to-point" -c "ip ospf cost 50" -c "end"
```

**Expected Output**: `Configuration saved`

**Validation**: GRE1 in OSPF with cost 50

**Rollback Trigger**: Cannot add to OSPF
**Rollback Command**: (same as above for router-b1)

---

#### Step 4.3: Verify OSPF Adjacency on New Tunnel
**Estimated Time**: 30 seconds (wait for convergence)
**Rollback Time**: N/A

**Commands**:
```bash
# Wait 10 seconds for OSPF adjacency to form
sleep 10
docker exec -it clab-enterprise-vpn-migration-router-a1 vtysh -c "show ip ospf neighbor"
```

**Expected Output**:
- Two neighbors visible (one on gre0, one on gre1)
- Both in FULL state

**Validation**: OSPF adjacency FULL on both tunnels

**Rollback Trigger**: OSPF not forming adjacency on gre1 after 30 seconds
**Rollback Actions**: Execute rollback procedure (remove gre1 from OSPF)

---

#### Step 4.4: Verify Traffic Using New Tunnel
**Estimated Time**: 1 minute
**Rollback Time**: N/A

**Commands**:
```bash
docker exec -it clab-enterprise-vpn-migration-router-a1 vtysh -c "show ip route 10.2.0.0/16"
docker exec -it clab-enterprise-vpn-migration-web-a traceroute -m 5 10.2.20.10
```

**Expected Output**:
- Route to Site B shows next-hop via gre1 (cost 50 preferred)
- Traceroute shows path through new tunnel

**Validation**: Traffic using new tunnel due to better OSPF cost

**Rollback Trigger**: Traffic still using old tunnel (cost manipulation failed)

---

### Phase 5: Remove Old Tunnel from OSPF (2 minutes)

---

#### Step 5.1: Remove GRE0 from OSPF on Router-A1
**Estimated Time**: 1 minute
**Rollback Time**: 30 seconds

**Commands**:
```bash
docker exec -it clab-enterprise-vpn-migration-router-a1 vtysh -c "conf t" -c "interface gre0" -c "no ip ospf area 0" -c "end"
```

**Expected Output**: `Configuration saved`

**Validation**: GRE0 no longer in OSPF interfaces
```bash
docker exec -it clab-enterprise-vpn-migration-router-a1 vtysh -c "show ip ospf interface" | grep gre0
```

**Rollback Trigger**: Services become unreachable
**Rollback Command**:
```bash
docker exec -it clab-enterprise-vpn-migration-router-a1 vtysh -c "conf t" -c "interface gre0" -c "ip ospf area 0" -c "ip ospf network point-to-point" -c "end"
```

---

#### Step 5.2: Remove GRE0 from OSPF on Router-B1
**Estimated Time**: 1 minute
**Rollback Time**: 30 seconds

**Commands**:
```bash
docker exec -it clab-enterprise-vpn-migration-router-b1 vtysh -c "conf t" -c "interface gre0" -c "no ip ospf area 0" -c "end"
```

**Expected Output**: `Configuration saved`

**Validation**: Only gre1 in OSPF, gre0 removed

**Rollback Trigger**: Services unreachable

---

#### Step 5.3: Verify Services Still Accessible
**Estimated Time**: 30 seconds
**Rollback Time**: N/A

**Commands**:
```bash
docker exec -it clab-enterprise-vpn-migration-web-a curl -s http://10.2.20.10 | grep "Welcome"
```

**Expected Output**: Web page content retrieved successfully

**Validation**: Services operational on new tunnel only

**⚠️ DOWNTIME WINDOW ENDS HERE ⚠️**
**End Time**: __________ (record actual time)
**Actual Downtime**: __________ seconds/minutes

---

### Phase 6: Clean Up Old Resources (3 minutes)

**Downtime Impact**: NONE (old tunnel already removed from routing)

---

#### Step 6.1: Shut Down Old Tunnel on Router-A1
**Estimated Time**: 1 minute
**Rollback Time**: 2 minutes

**Commands**:
```bash
docker exec -it clab-enterprise-vpn-migration-router-a1 ip link set gre0 down
docker exec -it clab-enterprise-vpn-migration-router-a1 ip tunnel del gre0
```

**Expected Output**: No errors

**Validation**: GRE0 no longer exists

**Rollback Trigger**: Accidental service disruption
**Rollback**: Run full rollback script (`./scripts/rollback.sh`)

---

#### Step 6.2: Shut Down Old Tunnel on Router-B1
**Estimated Time**: 1 minute
**Rollback Time**: 2 minutes

**Commands**:
```bash
docker exec -it clab-enterprise-vpn-migration-router-b1 ip link set gre0 down
docker exec -it clab-enterprise-vpn-migration-router-b1 ip tunnel del gre0
```

**Expected Output**: No errors

**Validation**: GRE0 deleted

---

#### Step 6.3: Remove Old WAN IP from Router-A1
**Estimated Time**: 30 seconds
**Rollback Time**: 1 minute

**Commands**:
```bash
docker exec -it clab-enterprise-vpn-migration-router-a1 ip addr del 203.0.113.10/30 dev eth2
docker exec -it clab-enterprise-vpn-migration-router-a1 ip addr show eth2
```

**Expected Output**: Only new IP `192.0.2.10/30` present

**Validation**: Old IP removed

---

#### Step 6.4: Remove Old WAN IP from Router-B1
**Estimated Time**: 30 seconds
**Rollback Time**: 1 minute

**Commands**:
```bash
docker exec -it clab-enterprise-vpn-migration-router-b1 ip addr del 198.51.100.10/30 dev eth2
docker exec -it clab-enterprise-vpn-migration-router-b1 ip addr show eth2
```

**Expected Output**: Only new IP `192.0.2.20/30` present

**Validation**: Old IP removed, migration to new IPs complete

---

### Phase 7: Post-Migration Validation (5 minutes)

---

#### Step 7.1: Run Automated Post-Migration Tests
**Estimated Time**: 2 minutes
**Rollback Time**: N/A

**Commands**:
```bash
cd /path/to/lab
./scripts/validate.sh --post-migration
```

**Expected Output**: All 6 post-migration tests pass (17-22)

**Validation**: 6/6 tests passed

**Rollback Trigger**: Any critical test fails (tests 17, 19, 20)

---

#### Step 7.2: Verify End-to-End Services
**Estimated Time**: 2 minutes
**Rollback Time**: N/A

**Commands**:
```bash
# Web accessibility
docker exec -it clab-enterprise-vpn-migration-web-a curl -s http://10.2.20.10
docker exec -it clab-enterprise-vpn-migration-web-b curl -s http://10.1.20.10

# DNS resolution
docker exec -it clab-enterprise-vpn-migration-web-a nslookup web-b.site-b.local 10.1.20.11

# LDAP connectivity
docker exec -it clab-enterprise-vpn-migration-server-b nc -zv 10.1.20.12 389
```

**Expected Output**: All services respond correctly

**Validation**: All inter-site services operational

---

#### Step 7.3: Check Grafana for Anomalies
**Estimated Time**: 1 minute
**Rollback Time**: N/A

**Actions**:
1. Access Grafana: `http://10.1.20.13:3000`
2. Check for error spikes during migration window
3. Verify traffic is flowing normally
4. Screenshot dashboard for change documentation

**Validation**: No sustained errors, traffic patterns normal

---

## Downtime Tracking

| Phase | Step | Start Time | End Time | Duration | Status |
|-------|------|-----------|----------|----------|--------|
| 4     | 4.1  |           |          |          |        |
| 4     | 4.2  |           |          |          |        |
| 4     | 4.3  |           |          |          |        |
| 4     | 4.4  |           |          |          |        |
| 5     | 5.1  |           |          |          |        |
| 5     | 5.2  |           |          |          |        |
| 5     | 5.3  |           |          |          |        |

**Total Downtime**: __________ seconds/minutes
**SLA Target**: 5 minutes
**SLA Status**: ✅ Met / ❌ Exceeded

---

## Rollback Procedure

**Trigger Conditions**:
- New GRE tunnel fails to establish (Step 3.3)
- OSPF adjacency not forming on new tunnel (Step 4.3)
- Traffic not using new tunnel (Step 4.4)
- Services unreachable after OSPF migration (Step 5.3)
- Any critical validation test fails

**Rollback Execution**:
```bash
cd /path/to/lab
./scripts/rollback.sh
```

**Rollback Steps** (manual if script unavailable):
1. Add gre0 back to OSPF on both routers
2. Remove gre1 from OSPF on both routers
3. Delete gre1 tunnel interfaces
4. Remove new WAN IPs (192.0.2.x)
5. Verify old configuration restored
6. Run pre-migration validation tests

**Rollback Time Target**: <3 minutes

---

## Post-Migration Tasks

- [ ] Update Netbox with new IP addresses
- [ ] Update network diagrams
- [ ] Notify stakeholders of successful completion
- [ ] Archive migration logs and validation results
- [ ] Schedule post-implementation review
- [ ] Update runbook with lessons learned
- [ ] Close change ticket
- [ ] Document actual vs. estimated downtime

---

## Lessons Learned

**What Went Well**:
- [To be filled after migration]

**What Could Be Improved**:
- [To be filled after migration]

**Unexpected Issues**:
- [To be filled after migration]

**Recommendations for Future Changes**:
- [To be filled after migration]

---

## Stakeholder Communication

### Pre-Migration Announcement
```
Subject: Scheduled VPN Maintenance - [Date] [Time]

Dear Team,

We will be performing scheduled maintenance on our site-to-site VPN on [Date] from [Start Time] to [End Time].

Expected Impact:
- Brief interruption (<5 minutes) to inter-site connectivity
- Web services between Chicago and Austin may be temporarily unavailable
- LDAP authentication may experience brief delay

During Maintenance:
- Avoid initiating large file transfers between sites
- Local services remain available

We will send updates as the maintenance progresses.

IT Network Team
```

### Post-Migration Announcement
```
Subject: VPN Maintenance Complete

The scheduled VPN maintenance has been completed successfully.

Results:
- Migration completed in [X] minutes
- Actual downtime: [X] minutes (within SLA)
- All services restored and operational

Thank you for your patience.

IT Network Team
```

---

## Approval

- [ ] Change Owner: _________________________ Date: _________
- [ ] Technical Reviewer: ____________________ Date: _________
- [ ] CAB Approval: _________________________ Date: _________

---

**Document Version**: 1.0
**Last Updated**: [YYYY-MM-DD]
