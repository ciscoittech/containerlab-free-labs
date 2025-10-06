# Exercise 2: Risk Assessment and Change Planning

## Objective

Identify risks associated with the VPN migration, plan mitigation strategies, and define rollback procedures.

## Prerequisites

- **Exercise 1 completed**: Network audit and documentation
- Understanding of current network architecture
- Service dependency map created

## Time Estimate

15-30 minutes

## Learning Outcomes

After completing this exercise, you will be able to:
- Identify single points of failure (SPOFs) in network infrastructure
- Assess service impact during planned changes
- Define rollback triggers and procedures
- Plan validation checkpoints for complex changes
- Create change management documentation

---

## Task 1: Identify Single Points of Failure (5 minutes)

### Instructions

Analyze the current network architecture and identify all single points of failure.

**Consider**:
- If this device/link fails, what services are affected?
- Is there redundancy or a backup path?
- Can we route around a failure?

### Questions to Answer

1. **GRE Tunnel Failure**:
   - What happens if the GRE tunnel (gre0) goes down?
   - Is there a backup path for Site A → Site B traffic?
   - Answer: _________________________________

2. **Router Failure**:
   - What happens if router-a1 (edge) fails?
   - What happens if router-a2 (core) fails?
   - Answer: _________________________________

3. **Firewall Failure**:
   - What happens if firewall-a fails?
   - Are services still accessible within Site A?
   - Answer: _________________________________

4. **DNS Service Failure**:
   - What happens if dns-a (10.1.20.11) fails?
   - Can Site B still resolve hostnames?
   - Answer: _________________________________

5. **ISP Failure**:
   - What happens if ISP-A (MegaNet) goes down?
   - Can BGP provide a backup path?
   - Answer: _________________________________

### Deliverable

**SPOF Analysis Table**:

| Component | Type | Failure Impact | Services Affected | Redundancy? | Mitigation |
|-----------|------|----------------|-------------------|-------------|------------|
| GRE tunnel (gre0) | Connectivity | Total inter-site outage | All cross-site services | No | BGP path exists but not configured for transit |
| router-a1 | Device | Site A loses WAN & VPN | All Site A services become isolated | No | Deploy secondary edge router (future) |
| firewall-a | Device | Site A servers unreachable | web-a, dns-a, ldap-a, grafana | No | Configure router-a2 for direct routing (emergency) |
| dns-a | Service | DNS resolution fails | Hostname-based access fails | No | Configure backup DNS server on Site B |
| ... | ... | ... | ... | ... | ... |

**Critical Finding**: How many SPOFs exist in this network? _______

---

## Task 2: Service Impact Analysis (10 minutes)

### Instructions

For the VPN migration specifically, identify which services will be affected and for how long.

### Migration Phases and Impact

**Phase 1: Add New WAN IPs (Dual-Stack)**
- Duration: ~3 minutes
- Downtime: None (adding IPs is non-disruptive)
- Services Affected: None
- Risk Level: **LOW**

**Phase 2: Create New GRE Tunnel**
- Duration: ~3 minutes
- Downtime: None (new tunnel in parallel with old)
- Services Affected: None
- Risk Level: **LOW**

**Phase 3: Migrate OSPF to New Tunnel** ⚠️ CRITICAL
- Duration: ~4 minutes
- Downtime: **2-3 minutes** (during OSPF convergence)
- Services Affected: **ALL inter-site services**
- Risk Level: **HIGH**

**Phase 4: Remove Old Tunnel**
- Duration: ~3 minutes
- Downtime: None (if new tunnel is working correctly)
- Services Affected: None (if successful)
- Risk Level: **MEDIUM** (could cause outage if new tunnel has hidden issues)

### Questions to Answer

1. **What is the total estimated downtime?**
   - Conservative estimate (sequential execution): _______
   - Optimized estimate (parallel where possible): _______

2. **Which phase has the highest risk?**
   - Answer: _________________________________
   - Why: _________________________________

3. **What services will be unavailable during downtime?**
   - Cross-site web access (web-a ↔ web-b): Yes/No
   - DNS resolution from Site B: Yes/No
   - LDAP authentication from Site B: Yes/No
   - Grafana monitoring: Yes/No
   - Local services within each site: Yes/No

### Deliverable

**Service Impact Matrix**:

| Service | Current Access | During Migration | Post-Migration | Max Downtime | Business Impact |
|---------|---------------|------------------|----------------|--------------|-----------------|
| Web-A from Site B | Available | **UNAVAILABLE** (2-3 min) | Available | 3 min | Medium - employee productivity |
| Web-B from Site A | Available | **UNAVAILABLE** (2-3 min) | Available | 3 min | Medium - employee productivity |
| DNS (cross-site) | Available | **UNAVAILABLE** (2-3 min) | Available | 3 min | High - all hostname resolution fails |
| LDAP Auth | Available | **UNAVAILABLE** (2-3 min) | Available | 3 min | High - authentication failures |
| Local Site A Services | Available | Available | Available | 0 min | None |
| Local Site B Services | Available | Available | Available | 0 min | None |
| Grafana | Available | Available | Available | 0 min | Low - located in Site A |

**Critical Services**: How many services have >2 minute downtime? _______

---

## Task 3: Define Rollback Triggers (5 minutes)

### Instructions

Identify specific conditions that should trigger an immediate rollback to the old configuration.

### Rollback Trigger Conditions

For each migration phase, define what failures would require rollback:

**Phase 1: Add New WAN IPs**
- Rollback if: Cannot add new IP address (IP conflict)
- Rollback if: Cannot ping new ISP gateway (ISP routing issue)
- Rollback action: Remove new IPs, abort migration

**Phase 2: Create New GRE Tunnel**
- Rollback if: Cannot create gre1 tunnel interface
- Rollback if: New tunnel does not come UP
- Rollback if: **Cannot ping across new tunnel after 1 minute**
- Rollback action: Delete gre1, remove new WAN IPs, abort migration

**Phase 3: Migrate OSPF to New Tunnel** ⚠️ CRITICAL
- Rollback if: OSPF adjacency not forming on new tunnel after 30 seconds
- Rollback if: **Services still unreachable after 5 minutes**
- Rollback if: Routing loops detected
- Rollback action: Remove gre1 from OSPF, re-add gre0 to OSPF immediately

**Phase 4: Remove Old Tunnel**
- Rollback if: Services become unreachable after old tunnel removed
- Rollback if: New tunnel unexpectedly fails
- Rollback action: **Run full rollback script** to restore old configuration

### Deliverable

**Rollback Trigger Decision Tree**:

```
Migration Step
    │
    ├─ Success? ──► Continue to next step
    │
    └─ Failure?
        │
        ├─ Minor issue? (e.g., delay in convergence)
        │   └─► Wait and monitor (up to 5 min SLA)
        │
        └─ Critical failure? (e.g., no connectivity after 2 min)
            └─► EXECUTE ROLLBACK IMMEDIATELY
                │
                ├─ Phase 1-2: Remove new resources, abort
                ├─ Phase 3: Revert OSPF to old tunnel
                └─ Phase 4: Full rollback script
```

**Rollback Authority**: Who can make the call to rollback?
- Primary: Change owner (you)
- Secondary: Network team lead
- Escalation: IT manager

---

## Task 4: Plan Validation Checkpoints (10 minutes)

### Instructions

Define specific validation steps after each phase to ensure safe progression.

### Validation Checkpoints

**Checkpoint 1: After Adding New WAN IPs**
```bash
# Verify dual-stack (both old and new IPs present)
docker exec clab-enterprise-vpn-migration-router-a1 ip addr show eth2 | grep inet

# Expected: See both 203.0.113.10 AND 192.0.2.10

# Test new IP connectivity
docker exec clab-enterprise-vpn-migration-router-a1 ping -c 3 -I 192.0.2.10 192.0.2.9

# Expected: 3/3 packets received
```
**Pass Criteria**: Both IPs configured, can ping new gateway
**Fail Action**: If fail, remove new IPs and abort

---

**Checkpoint 2: After Creating New GRE Tunnel**
```bash
# Verify tunnel exists and is UP
docker exec clab-enterprise-vpn-migration-router-a1 ip link show gre1 | grep "state UP"

# Test tunnel connectivity
docker exec clab-enterprise-vpn-migration-router-a1 ping -c 5 172.16.1.2

# Expected: 5/5 packets received, low latency (<5ms)
```
**Pass Criteria**: New tunnel UP, bidirectional ping succeeds
**Fail Action**: If fail, delete new tunnel, remove new IPs, abort

---

**Checkpoint 3: After Adding New Tunnel to OSPF**
```bash
# Verify OSPF adjacency on new tunnel
docker exec clab-enterprise-vpn-migration-router-a1 vtysh -c "show ip ospf neighbor" | grep 172.16.1

# Expected: Neighbor state "Full"

# Verify routes learned via new tunnel
docker exec clab-enterprise-vpn-migration-router-a1 vtysh -c "show ip route 10.2.0.0/16"

# Expected: Route via gre1 (better cost than gre0)
```
**Pass Criteria**: OSPF Full, traffic using new tunnel due to better cost
**Fail Action**: If fail after 30 sec, remove gre1 from OSPF

---

**Checkpoint 4: After Removing Old Tunnel from OSPF** ⚠️ CRITICAL
```bash
# Verify services still accessible
docker exec clab-enterprise-vpn-migration-web-a curl -s http://10.2.20.10 | grep "Welcome"

# Expected: HTTP 200, page content retrieved

# Verify only new tunnel has OSPF
docker exec clab-enterprise-vpn-migration-router-a1 vtysh -c "show ip ospf interface" | grep gre

# Expected: Only gre1 listed, gre0 not in OSPF
```
**Pass Criteria**: Services accessible via new tunnel only
**Fail Action**: If fail, immediately add gre0 back to OSPF (rollback)

---

**Checkpoint 5: Final Validation**
```bash
# Run automated post-migration tests
./scripts/validate.sh --post-migration

# Expected: 6/6 tests pass (tests 17-22)
```
**Pass Criteria**: All 6 post-migration tests pass
**Fail Action**: If critical tests fail (17, 19), execute full rollback

### Deliverable

**Validation Checkpoint Table**:

| Checkpoint | After Phase | Validation Commands | Pass Criteria | Time Limit | Fail Action |
|------------|-------------|---------------------|---------------|------------|-------------|
| 1 | Add new WAN IPs | ip addr show, ping new gateway | Both IPs present, ping succeeds | 2 min | Abort, remove new IPs |
| 2 | Create new tunnel | ip link show gre1, ping 172.16.1.2 | Tunnel UP, 5/5 ping | 2 min | Abort, delete gre1 |
| 3 | Add gre1 to OSPF | show ip ospf neighbor | OSPF Full on gre1 | 30 sec | Remove from OSPF, abort |
| 4 | Remove gre0 from OSPF | curl web-b, show ip ospf | Services work, only gre1 | 1 min | Add gre0 back (rollback) |
| 5 | Post-migration | validate.sh --post-migration | 6/6 tests pass | 5 min | Full rollback |

---

## Task 5: Create Rollback Procedure Document (10 minutes)

### Instructions

Write a detailed, step-by-step rollback procedure that can be executed quickly under pressure.

### Deliverable

**Rollback Procedure - VPN Migration**

---

**When to Execute**: Any critical validation checkpoint fails (see Task 4)

**Execution Time**: Target <3 minutes

**Prerequisites**:
- Access to all lab containers
- Rollback script available: `./scripts/rollback.sh`

---

**Automated Rollback (Preferred)**:
```bash
cd /path/to/enterprise-vpn-migration
./scripts/rollback.sh
```

**Estimated time**: 2-3 minutes

---

**Manual Rollback Steps** (if script unavailable):

**Step 1: Remove New Tunnel from OSPF (30 seconds)**
```bash
docker exec clab-enterprise-vpn-migration-router-a1 vtysh -c "conf t" \
  -c "interface gre1" -c "no ip ospf area 0" -c "end"
docker exec clab-enterprise-vpn-migration-router-b1 vtysh -c "conf t" \
  -c "interface gre1" -c "no ip ospf area 0" -c "end"
```

**Step 2: Re-add Old Tunnel to OSPF (30 seconds)**
```bash
docker exec clab-enterprise-vpn-migration-router-a1 vtysh -c "conf t" \
  -c "interface gre0" -c "ip ospf area 0" -c "ip ospf network point-to-point" -c "end"
docker exec clab-enterprise-vpn-migration-router-b1 vtysh -c "conf t" \
  -c "interface gre0" -c "ip ospf network point-to-point" -c "end"
```

**Step 3: Wait for OSPF Convergence (15 seconds)**
```bash
sleep 15
```

**Step 4: Verify Services Restored (30 seconds)**
```bash
docker exec clab-enterprise-vpn-migration-web-a curl -s http://10.2.20.10
# Expected: Web page content
```

**Step 5: Clean Up New Resources (1 minute)**
```bash
# Shut down and delete new tunnel
docker exec clab-enterprise-vpn-migration-router-a1 ip link set gre1 down
docker exec clab-enterprise-vpn-migration-router-a1 ip tunnel del gre1
docker exec clab-enterprise-vpn-migration-router-b1 ip link set gre1 down
docker exec clab-enterprise-vpn-migration-router-b1 ip tunnel del gre1

# Remove new WAN IPs
docker exec clab-enterprise-vpn-migration-router-a1 ip addr del 192.0.2.10/30 dev eth2
docker exec clab-enterprise-vpn-migration-router-b1 ip addr del 192.0.2.20/30 dev eth2
```

**Step 6: Final Validation (30 seconds)**
```bash
./scripts/validate.sh --pre-migration
# Expected: All 16 baseline tests pass
```

---

**Rollback Verification**:
- [ ] Old tunnel (gre0) back in OSPF
- [ ] Services accessible across VPN
- [ ] New tunnel (gre1) removed
- [ ] New WAN IPs removed
- [ ] Baseline validation tests pass

**Post-Rollback Actions**:
1. Notify stakeholders of rollback
2. Document reason for failure
3. Schedule root cause analysis meeting
4. Update migration plan based on lessons learned
5. Reschedule migration attempt

---

## Verification

Before moving to the next exercise, verify you have completed:

- [ ] SPOF analysis table (minimum: 5 SPOFs identified)
- [ ] Service impact matrix showing downtime per service
- [ ] Rollback trigger conditions for each phase
- [ ] Validation checkpoints with pass/fail criteria
- [ ] Documented rollback procedure (automated and manual)
- [ ] Estimated total downtime (should be <5 minutes)

---

## Next Exercise

Proceed to **Exercise 3: Change Planning** (`exercises/03-change-planning.md`)

---

## Reference

- [Migration Runbook Template](../docs/migration-runbook.md)
- [Troubleshooting Guide](../docs/troubleshooting.md)
- [Rollback Script](../scripts/rollback.sh)
