# Enterprise VPN Migration Scenario

## Business Context

You are a network engineer at **TechCorp Industries**, a mid-sized manufacturing company with two locations:

- **Site A (Headquarters)**: Chicago, IL - Main office with 200 employees
- **Site B (Remote Office)**: Austin, TX - Engineering office with 50 employees

The two sites are connected via a **GRE over IPsec VPN tunnel** across the public internet. This VPN carries critical traffic including:
- Centralized DNS services (dns-a at HQ serves both sites)
- LDAP/Active Directory authentication
- Internal web applications
- Inter-office file sharing
- VoIP traffic

## The Problem

Your ISP, **MegaNet Communications**, is undergoing a network restructure and has notified you that your current WAN IP addresses will be decommissioned in 30 days. You must migrate to new IP addresses provided by the ISP.

**Current VPN Endpoints**:
- Site A: `203.0.113.10/30` (old IP range)
- Site B: `198.51.100.10/30` (old IP range)

**New VPN Endpoints** (assigned by ISP):
- Site A: `192.0.2.10/30` (new IP range)
- Site B: `192.0.2.20/30` (new IP range)

## Business Requirements

### Critical Requirements
1. **Minimal Downtime**: Maximum 5 minutes of VPN outage during business hours (10 AM - 4 PM CT)
2. **Zero Data Loss**: No dropped database transactions or file transfers
3. **Service Continuity**: All services must be available before and after migration
4. **Rollback Plan**: Ability to revert to old configuration within 2 minutes if migration fails

### Stakeholder Concerns

**CIO's Requirements**:
- "Our engineers in Austin must access the LDAP server in Chicago for authentication"
- "We cannot afford extended downtime - our manufacturing systems depend on this VPN"
- "I need a detailed runbook before we proceed"

**IT Manager's Requirements**:
- "Ensure DNS continues to work - all our internal systems use DNS names, not IPs"
- "Test everything before declaring success - I don't want surprises on Monday morning"
- "Update our Netbox documentation immediately after completion"

**Security Team's Requirements**:
- "The IPsec tunnel must re-establish with the same security policies"
- "Verify firewall rules still work after the migration"
- "Ensure no unencrypted traffic leaks during the changeover"

## Network Architecture

### Site A - Chicago Headquarters (8 devices)

```
    [Internet]
        |
    [ISP-A Gateway] (100.64.0.1)
        |
        | WAN: 203.0.113.10/30 (OLD) → 192.0.2.10/30 (NEW)
        |
    [Router-A1] (Edge Router + VPN Endpoint)
        | BGP to ISP
        | GRE Tunnel to Site B
        |
        | OSPF
        |
    [Router-A2] (Core Router)
        |
    [Firewall-A] (Zone-based Security)
        |
    +---+---+---+---+
    |   |   |   |
  Web DNS LDAP Monitor
  .10 .11 .12  .13
```

**Site A Networks**:
- Management: `10.1.10.0/24` (router-a2: .1, servers: .10-.50)
- Servers: `10.1.20.0/24` (web: .10, dns: .11, ldap: .12, monitor: .13)
- WAN (Current): `203.0.113.10/30`
- WAN (New): `192.0.2.10/30`

### Site B - Austin Remote Office (5 devices)

```
    [Internet]
        |
    [ISP-B Gateway] (100.64.0.2)
        |
        | WAN: 198.51.100.10/30 (OLD) → 192.0.2.20/30 (NEW)
        |
    [Router-B1] (Edge Router + VPN Endpoint)
        | BGP to ISP
        | GRE Tunnel to Site A
        |
        | OSPF
        |
    [Router-B2] (Core Router)
        |
    [Firewall-B] (Zone-based Security)
        |
    +---+---+
    |   |
  Web Server
  .10 .11
```

**Site B Networks**:
- Management: `10.2.10.0/24` (router-b2: .1, servers: .10-.20)
- Servers: `10.2.20.0/24` (web: .10, server: .11)
- WAN (Current): `198.51.100.10/30`
- WAN (New): `192.0.2.20/30`

### VPN Tunnel Configuration

**GRE Tunnel** (Layer 3 VPN):
- Tunnel subnet: `172.16.0.0/30`
- Site A endpoint: `172.16.0.1` (router-a1)
- Site B endpoint: `172.16.0.2` (router-b1)
- Tunnel source: Old WAN IPs (to be migrated to new IPs)

**IPsec Encryption** (ESP transport mode):
- IKEv2 with pre-shared key authentication
- AES-256-GCM encryption
- Perfect Forward Secrecy (PFS) enabled
- Dead Peer Detection (DPD) enabled

**Routing**:
- OSPF within each site (area 0)
- BGP to ISP for internet routes
- Static routes for VPN subnets

## Service Dependencies

### Critical Services Over VPN

1. **DNS (Port 53 UDP/TCP)**
   - Direction: Site B → Site A (dns-a at 10.1.20.11)
   - Impact if down: Name resolution fails, most services break
   - SLA: Must restore within 2 minutes

2. **LDAP (Port 389 TCP)**
   - Direction: Site B → Site A (ldap-a at 10.1.20.12)
   - Impact if down: Users in Austin cannot log in
   - SLA: Must restore within 5 minutes

3. **Internal Web Apps (Port 80/443 TCP)**
   - Direction: Bidirectional
   - Site A Web: 10.1.20.10
   - Site B Web: 10.2.20.10
   - Impact if down: Workflow disruption, not critical
   - SLA: Must restore within 5 minutes

4. **Monitoring (Port 3000 TCP)**
   - Direction: Site B → Site A (monitor-a at 10.1.20.13)
   - Impact if down: No real-time visibility (but not service-critical)
   - SLA: Nice to have

## Migration Challenges

### Technical Challenges You'll Face

1. **Routing Convergence**:
   - BGP sessions will flap when WAN IPs change
   - OSPF must reconverge after tunnel reconfiguration
   - Timing is critical to minimize downtime

2. **IPsec Tunnel Re-establishment**:
   - Changing tunnel source IPs requires IPsec renegotiation
   - Dead Peer Detection (DPD) timeout is 30 seconds
   - Manual intervention may be needed to force tunnel up

3. **DNS Propagation**:
   - Internal DNS records point to services by name
   - Ensure DNS server (dns-a) remains reachable during migration
   - Consider DNS caching timeouts

4. **Firewall State Tables**:
   - Zone-based firewall rules reference old IP ranges
   - Connection tracking may retain old tunnel sessions
   - May need to flush state tables

5. **Service Health Monitoring**:
   - Grafana dashboard must continue to collect metrics
   - Netbox IPAM must be updated to reflect new IPs
   - Alert systems may trigger false positives during migration

### Risk Mitigation Strategies

**Pre-Migration Preparation**:
- [ ] Document current configuration (backup all configs)
- [ ] Test rollback procedure in lab environment
- [ ] Notify users of maintenance window
- [ ] Stage new IP configurations on both routers
- [ ] Pre-configure monitoring to track migration progress

**During Migration**:
- [ ] Keep old and new configurations side-by-side temporarily
- [ ] Establish out-of-band access (SSH to management IPs)
- [ ] Monitor VPN tunnel status continuously
- [ ] Verify each service immediately after tunnel restoration

**Post-Migration**:
- [ ] Run comprehensive validation tests
- [ ] Monitor for 30+ minutes before declaring success
- [ ] Update documentation (Netbox, runbooks, diagrams)
- [ ] Schedule post-mortem to document lessons learned

## Your Mission

As the network engineer responsible for this migration, you must:

1. **Phase 1: Discovery & Planning (30-45 minutes)**
   - SSH to all 16 devices and document IP addressing
   - Map service dependencies (DNS, LDAP, Web)
   - Identify VPN tunnel configuration on router-a1 and router-b1
   - Create detailed migration runbook

2. **Phase 2: Pre-Migration Validation (20-30 minutes)**
   - Verify all services are working over current VPN
   - Test DNS resolution from Site B to Site A
   - Test web connectivity bidirectionally
   - Test LDAP authentication from Site B
   - Document baseline performance metrics

3. **Phase 3: Migration Execution (15-30 minutes)**
   - Follow runbook to migrate WAN IPs
   - Reconfigure GRE tunnel source/destination IPs
   - Update IPsec tunnel peer IPs
   - Restart tunnels and verify establishment
   - Update routing protocols (BGP, OSPF)

4. **Phase 4: Post-Migration Validation (20-30 minutes)**
   - Re-run all pre-migration tests
   - Verify DNS, Web, LDAP services restored
   - Check Grafana for healthy metrics
   - Update Netbox with new IP assignments
   - Monitor tunnel stability for 30 minutes

5. **Phase 5: Documentation & Closure (15-20 minutes)**
   - Update network diagrams
   - Document actual downtime achieved
   - Note any unexpected issues encountered
   - Archive old configurations for reference

## Success Criteria

### Technical Success
- ✅ VPN tunnel established on new IPs (192.0.2.10 ↔ 192.0.2.20)
- ✅ All services restored (DNS, LDAP, Web)
- ✅ Downtime under 5 minutes
- ✅ No routing loops or black holes
- ✅ Firewall policies functional

### Business Success
- ✅ No user complaints about service interruptions
- ✅ CIO satisfied with downtime duration
- ✅ IT Manager confirms documentation updated
- ✅ Security team confirms encryption maintained

### Bonus Achievements
- 🏆 Zero-downtime migration using dual-tunnel approach
- 🏆 Automated validation script created
- 🏆 Grafana dashboard shows VPN metrics in real-time
- 🏆 Rollback procedure tested and documented

## Real-World Context

This scenario is based on common enterprise situations:

- **ISP migrations**: Changing internet providers requires new WAN IPs
- **Data center moves**: Relocating offices results in new IP assignments
- **Security incidents**: IP ranges may need changing due to DDoS attacks
- **Network consolidation**: Merging companies requires IP renumbering
- **Technology refresh**: Upgrading VPN appliances often means new IPs

**Career Skills Developed**:
- Change management in production environments
- Risk assessment and mitigation
- Service continuity planning
- Network documentation practices
- Communication with non-technical stakeholders

## Timeline

**Week 1**: Receive notification from ISP about IP decommission (30-day notice)
**Week 2**: Lab testing and runbook creation (this lab environment)
**Week 3**: Stakeholder communication and maintenance window approval
**Week 4**: Production migration execution (scheduled for Saturday 2 AM CT)

**You are here**: Week 2 - Lab testing phase

---

**Good luck, Network Engineer! The success of this migration depends on your thorough planning and careful execution.**
