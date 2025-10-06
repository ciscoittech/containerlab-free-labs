# Technology Decisions & Architecture Notes

## Platform Selection Rationale

### Core Routing Platform: FRR 9.1.0

**Selected For**: router-a1, router-a2, router-b1, router-b2, internet-core

**Why FRR**:
- ✅ **GRE Tunnel Support**: Native GRE tunnel interface creation and management
- ✅ **Multi-Protocol**: OSPF, BGP, and static routing in single container
- ✅ **Cisco-like Syntax**: Familiar `vtysh` CLI for network engineers
- ✅ **Lightweight**: ~100-150MB memory per instance
- ✅ **Production-Ready**: Used in real-world ISP and enterprise networks
- ✅ **Apache 2.0 License**: Fully permissive for educational and commercial use

**FRR Daemons Enabled**:
- `zebra`: Kernel routing table management
- `ospfd`: OSPF intra-site routing
- `bgpd`: BGP inter-site and ISP peering
- `staticd`: Static routes for VPN and management networks

**Alternative Considered**: SR Linux
- ❌ Rejected: SR Linux doesn't support GRE tunnels natively
- ❌ Over-engineered for this use case (EVPN/VXLAN is overkill)
- ✅ FRR better matches enterprise VPN scenarios

### Firewall Platform: VyOS Latest

**Selected For**: firewall-a, firewall-b

**Why VyOS**:
- ✅ **Zone-Based Firewall**: Realistic enterprise security policies
- ✅ **IPsec Support**: Native strongSwan integration for VPN encryption
- ✅ **Stateful Inspection**: Connection tracking and NAT support
- ✅ **Lightweight**: ~200MB memory per instance
- ✅ **Vyatta Syntax**: Industry-standard configuration style
- ✅ **Open Source**: Community edition freely available

**VyOS Features Used**:
- Zone-based firewall (LAN, WAN, VPN zones)
- IPsec IKEv2 with pre-shared keys
- Dead Peer Detection (DPD) for tunnel monitoring
- Firewall rules for service access control

**Alternative Considered**: iptables on Alpine
- ❌ Rejected: Too low-level for learning zone-based firewall concepts
- ❌ No native IPsec integration (would need separate strongSwan setup)
- ✅ VyOS provides better learning value for enterprise scenarios

### Server Platform: Alpine Linux 3.18

**Selected For**: isp-a, isp-b, web-a, web-b, dns-a, ldap-a, server-b

**Why Alpine**:
- ✅ **Minimal Footprint**: ~50MB memory per container
- ✅ **Fast Startup**: <2 seconds to full boot
- ✅ **Package Manager**: `apk` provides nginx, dnsmasq, openldap, etc.
- ✅ **Security**: Minimal attack surface, no unnecessary services
- ✅ **Educational Value**: Teaches lightweight Linux administration

**Services Deployed**:
- **nginx**: Web servers (web-a, web-b) on port 80
- **dnsmasq**: DNS server (dns-a) on port 53
- **openldap**: LDAP directory (ldap-a) on port 389
- **Network tools**: curl, ping, traceroute for testing

**Alternative Considered**: Ubuntu containers
- ❌ Rejected: 10x larger memory footprint (~500MB each)
- ❌ Slower startup times
- ✅ Alpine better for lab environments with 16 containers

### Monitoring Platform: Grafana Latest

**Selected For**: monitor-a

**Why Grafana**:
- ✅ **Industry Standard**: Real-world enterprise monitoring tool
- ✅ **Pre-built Dashboards**: Network metrics visualization
- ✅ **Lightweight**: ~150MB memory
- ✅ **Educational Value**: Teaches observability concepts

**Grafana Configuration**:
- Default login: admin/admin
- Pre-configured data source: Prometheus (future enhancement)
- Dashboard for VPN tunnel metrics (packet loss, latency, throughput)

**Alternative Considered**: Simple Nagios
- ❌ Rejected: Outdated UI, less relevant to modern DevOps workflows
- ✅ Grafana better prepares students for cloud-native monitoring

### IPAM Platform: Netbox Community Edition

**Selected For**: netbox

**Why Netbox**:
- ✅ **Industry Standard**: De facto IPAM/DCIM tool for network engineers
- ✅ **IP Address Management**: Document old vs new IP assignments
- ✅ **Topology Visualization**: Network diagrams and device relationships
- ✅ **RESTful API**: Automation-ready for future enhancements
- ✅ **Educational Value**: Real-world network documentation practices

**Netbox Pre-Seeded Data**:
- Device inventory (all 16 devices)
- IP address assignments (old and new ranges)
- VPN tunnel documentation
- Site hierarchy (Site A, Site B)

**Alternative Considered**: Spreadsheet/Markdown docs
- ❌ Rejected: Doesn't teach industry-standard IPAM workflows
- ✅ Netbox provides better career-relevant skills

## Network Design Decisions

### IP Addressing Scheme

**Site A (Headquarters) - 10.1.0.0/16**:
```
10.1.10.0/24    Management Network
  .1            router-a2 (core router management)
  .10-.50       Reserved for server management IPs

10.1.20.0/24    Server Network
  .1            Default gateway (router-a2)
  .10           web-a (nginx web server)
  .11           dns-a (dnsmasq DNS server)
  .12           ldap-a (OpenLDAP directory)
  .13           monitor-a (Grafana dashboard)
```

**Site B (Remote Office) - 10.2.0.0/16**:
```
10.2.10.0/24    Management Network
  .1            router-b2 (core router management)
  .10-.20       Reserved for server management IPs

10.2.20.0/24    Server Network
  .1            Default gateway (router-b2)
  .10           web-b (nginx web server)
  .11           server-b (general application server)
```

**WAN IP Addressing**:
```
OLD IP RANGES (to be migrated from):
  203.0.113.0/30    Site A WAN (router-a1: .10)
  198.51.100.0/30   Site B WAN (router-b1: .10)

NEW IP RANGES (migration target):
  192.0.2.0/30      Site A WAN (router-a1: .10)
  192.0.2.16/30     Site B WAN (router-b1: .20)
```

**VPN Tunnel Addressing**:
```
172.16.0.0/30     GRE Tunnel Subnet
  .1              router-a1 (Site A endpoint)
  .2              router-b1 (Site B endpoint)
```

**Internet Backbone**:
```
100.64.0.0/24     ISP Core Network (simulated internet)
  .1              ISP-A gateway (simulated upstream ISP)
  .2              ISP-B gateway (simulated upstream ISP)
  .254            internet-core (FRR router simulating ISP backbone)
```

**Rationale**:
- Private IP ranges for internal networks (RFC 1918)
- TEST-NET ranges for WAN IPs (RFC 5737) - safe for labs
- Shared Address Space (100.64.0.0/10) for ISP simulation (RFC 6598)
- /30 subnets for point-to-point links (efficient addressing)

### Routing Protocol Selection

**OSPF (Intra-Site Routing)**:
- Used within Site A and Site B for internal reachability
- Area 0 (backbone area) only
- All routers and servers in same area
- Fast convergence (<5 seconds) for internal failures

**BGP (Inter-Site Routing)**:
- BGP peering between router-a1/router-b1 and internet-core
- Simulates ISP connectivity
- AS Numbers:
  - AS 64512: Site A (router-a1)
  - AS 64513: Site B (router-b1)
  - AS 65000: ISP (internet-core)
- eBGP for WAN routing, iBGP unnecessary (single router per site)

**Static Routes**:
- Default route (0.0.0.0/0) via BGP
- VPN tunnel routes via GRE interface
- Management network routes to core routers

**Rationale**:
- OSPF chosen over EIGRP (Cisco proprietary, FRR support limited)
- BGP required for ISP simulation (realistic enterprise scenario)
- Static routes for simplicity where dynamic routing unnecessary

### VPN Tunnel Architecture

**Why GRE over IPsec (Not Just IPsec)**:
- ✅ **Multi-Protocol Support**: GRE can carry IPv4, IPv6, multicast
- ✅ **Routing Protocol Support**: OSPF/BGP can run over GRE tunnels
- ✅ **Flexibility**: Easier to troubleshoot than pure IPsec tunnel mode
- ✅ **Enterprise Standard**: Common in Cisco/Juniper networks

**GRE Tunnel Configuration**:
```
Interface: gre0
Tunnel source: WAN IP (203.0.113.10 or 192.0.2.10)
Tunnel destination: Remote WAN IP
Tunnel mode: gre ip
IP address: 172.16.0.1/30 or 172.16.0.2/30
MTU: 1400 (accounts for GRE + IPsec overhead)
```

**IPsec ESP Configuration**:
```
IKE (Phase 1):
  Protocol: IKEv2
  Encryption: AES-256-GCM
  Authentication: Pre-Shared Key
  DH Group: 14 (2048-bit)
  Lifetime: 28800 seconds (8 hours)

ESP (Phase 2):
  Encryption: AES-256-GCM
  Authentication: Null (GCM provides AEAD)
  PFS Group: 14
  Lifetime: 3600 seconds (1 hour)
```

**Dead Peer Detection (DPD)**:
- Enabled for tunnel health monitoring
- Interval: 30 seconds
- Timeout: 120 seconds
- Action: Restart tunnel on failure

**Rationale**:
- GRE+IPsec mirrors real enterprise VPN deployments
- IKEv2 provides faster reconnection than IKEv1
- AES-256-GCM offers encryption + authentication in single operation
- DPD ensures tunnel failures detected quickly

## Container Resource Allocation

### Memory Budget (Total: ~4GB)

| Container Type | Count | Memory Each | Total Memory |
|---------------|-------|-------------|--------------|
| FRR Routers | 5 | 150 MB | 750 MB |
| VyOS Firewalls | 2 | 200 MB | 400 MB |
| Alpine Servers | 7 | 50 MB | 350 MB |
| Grafana | 1 | 150 MB | 150 MB |
| Netbox | 1 | 300 MB | 300 MB |
| **Total** | **16** | | **~2 GB** |

**Safety Margin**: 2GB actual vs 4GB target (50% headroom for spikes)

### CPU Allocation
- No hard CPU limits (shared CPU model)
- FRR routing processes: ~5-10% CPU each during convergence
- IPsec encryption: ~10-20% CPU during high throughput
- Total CPU usage: <30% of 8-core system under normal load

### Disk Space
- Each container: ~100-300 MB disk space
- Total disk usage: ~3-4 GB for all containers
- Logs and persistent data: ~500 MB

**Rationale**:
- Fits comfortably on 16GB RAM VPS (Hetzner CPX41)
- Allows 6-8 concurrent lab users on single VPS
- Fast startup (<30 seconds for full 16-container deployment)

## Network Topology Links

### Total Links: 24 point-to-point connections

**Site A Internal Links (7)**:
1. router-a1 eth1 ↔ router-a2 eth1 (OSPF)
2. router-a2 eth2 ↔ firewall-a eth1 (LAN uplink)
3. firewall-a eth2 ↔ web-a eth1
4. firewall-a eth3 ↔ dns-a eth1
5. firewall-a eth4 ↔ ldap-a eth1
6. firewall-a eth5 ↔ monitor-a eth1
7. router-a1 eth2 ↔ isp-a eth1 (WAN connection)

**Site B Internal Links (5)**:
8. router-b1 eth1 ↔ router-b2 eth1 (OSPF)
9. router-b2 eth2 ↔ firewall-b eth1 (LAN uplink)
10. firewall-b eth2 ↔ web-b eth1
11. firewall-b eth3 ↔ server-b eth1
12. router-b1 eth2 ↔ isp-b eth1 (WAN connection)

**Internet Backbone Links (4)**:
13. isp-a eth2 ↔ internet-core eth1 (ISP upstream)
14. isp-b eth2 ↔ internet-core eth2 (ISP upstream)
15. router-a1 eth3 ↔ internet-core eth3 (BGP peering, backup path)
16. router-b1 eth3 ↔ internet-core eth4 (BGP peering, backup path)

**Management Links (2)**:
17. netbox eth1 ↔ router-a2 eth3 (out-of-band management)
18. monitor-a eth2 ↔ router-a2 eth4 (metrics collection)

**Virtual Links (GRE Tunnel) (1)**:
19. router-a1 gre0 ↔ router-b1 gre0 (VPN tunnel over internet)

**Rationale**:
- Point-to-point links simplify troubleshooting (no shared LANs)
- Firewall as central hub for each site (enforces security policies)
- Dual-homed ISP connections (primary via ISP gateway, backup via internet-core)
- Out-of-band management network (netbox accessible even if production down)

## Security Design

### Firewall Zones

**Site A Firewall (firewall-a)**:
```
LAN Zone:    web-a, dns-a, ldap-a, monitor-a (10.1.20.0/24)
WAN Zone:    router-a1 uplink (untrusted)
VPN Zone:    GRE tunnel traffic (172.16.0.0/30)
Management:  router-a2 (10.1.10.0/24)
```

**Site B Firewall (firewall-b)**:
```
LAN Zone:    web-b, server-b (10.2.20.0/24)
WAN Zone:    router-b1 uplink (untrusted)
VPN Zone:    GRE tunnel traffic (172.16.0.0/30)
Management:  router-b2 (10.2.10.0/24)
```

### Firewall Policies

**LAN → VPN** (Allowed):
- DNS queries (port 53)
- LDAP auth (port 389)
- HTTP/HTTPS (ports 80, 443)
- ICMP ping

**VPN → LAN** (Allowed):
- DNS responses (port 53, stateful)
- LDAP responses (port 389, stateful)
- HTTP/HTTPS responses (stateful)
- ICMP echo-reply

**LAN → WAN** (Denied):
- Block all direct internet access from servers
- Force traffic through VPN for inter-site

**WAN → LAN** (Denied):
- Block all inbound from internet
- IPsec/GRE traffic allowed (stateful)

**Rationale**:
- Defense-in-depth: Firewall + IPsec encryption
- Zone-based policies teach real enterprise security
- Stateful inspection prevents unauthorized return traffic

## Lab Initialization Automation

### Containerlab Boot Sequence

**Stage 1: Container Creation** (parallel, ~10 seconds):
- All 16 containers created simultaneously
- Base images pulled from registries
- Management network (172.20.20.0/24) assigned

**Stage 2: Network Links** (sequential, ~5 seconds):
- 24 point-to-point veth pairs created
- Linux bridges for multi-access segments
- Interface naming and IP assignment

**Stage 3: Service Initialization** (parallel, ~10 seconds):
- FRR daemons start (zebra, ospfd, bgpd, staticd)
- VyOS boot and config load
- Alpine services (nginx, dnsmasq, openldap)
- Grafana and Netbox startup

**Stage 4: Configuration Application** (parallel, ~5 seconds):
- FRR configs loaded from `configs/` directory
- VyOS configs applied via boot scripts
- DNS zone files loaded
- LDAP directory initialized

**Total Deployment Time**: ~30 seconds for full 16-container lab

### Pre-Migration State (Baseline)

**Automatically Configured**:
- ✅ All containers running and healthy
- ✅ OSPF adjacencies established (Site A, Site B)
- ✅ BGP peerings established (routers ↔ internet-core)
- ✅ GRE tunnel UP on OLD IPs (203.0.113.10 ↔ 198.51.100.10)
- ✅ IPsec tunnel established (encryption active)
- ✅ DNS server (dns-a) serving both sites
- ✅ LDAP server (ldap-a) accepting authentication
- ✅ Web servers (web-a, web-b) serving HTTP content
- ✅ Grafana accessible at http://10.1.20.13:3000
- ✅ Netbox accessible at http://10.1.20.14:8000

**Student's Task**:
- Migrate VPN from old IPs to new IPs
- Validate all services still work
- Document the migration process

## Testing Strategy

### Validation Test Categories

**Category 1: Infrastructure Health** (Tests 1-4):
- Container runtime status
- Network interface states
- IP address assignments
- Routing table population

**Category 2: Routing Protocols** (Tests 5-8):
- OSPF neighbor adjacencies
- BGP peering states
- Route advertisements
- Convergence timing

**Category 3: VPN Tunnel** (Tests 9-12):
- GRE tunnel interface status
- IPsec SA (Security Association) state
- Tunnel traffic encryption
- MTU and fragmentation handling

**Category 4: Application Services** (Tests 13-16):
- DNS resolution (forward and reverse)
- LDAP bind operations
- HTTP connectivity (curl tests)
- Service response times

**Category 5: Migration Validation** (Tests 17-20):
- New IP assignments verified
- Old IP configs removed
- No routing loops
- Service continuity confirmed

**Category 6: Monitoring & Documentation** (Tests 21-22):
- Grafana dashboard functional
- Netbox updated with new IPs

**Test Execution Order**:
1. Pre-migration: Run tests 1-16 (baseline)
2. During migration: Monitor tests 9-12 (tunnel status)
3. Post-migration: Re-run tests 1-22 (full validation)

**Expected Test Results**:
- Pre-migration: 16/16 tests pass
- Post-migration: 22/22 tests pass
- Downtime window: Tests 9-16 fail for <5 minutes

## Performance Benchmarks

### Baseline Performance Targets

**Routing Convergence**:
- OSPF: <5 seconds for adjacency formation
- BGP: <10 seconds for route advertisement
- Static routes: Immediate

**VPN Tunnel Metrics**:
- GRE tunnel MTU: 1400 bytes (accounts for overhead)
- IPsec throughput: ~500 Mbps (limited by CPU encryption)
- Tunnel latency: <5 ms added latency
- Packet loss: <0.1% under normal conditions

**Service Response Times**:
- DNS query: <50 ms
- LDAP bind: <100 ms
- HTTP request: <200 ms
- Ping (Site A ↔ Site B): <10 ms

**Migration Downtime**:
- Target: <5 minutes total VPN downtime
- Best case: <2 minutes (with scripted automation)
- Worst case: <10 minutes (if manual rollback needed)

**Resource Utilization**:
- Memory: ~2 GB steady-state
- CPU: <20% average, <60% during convergence
- Disk I/O: Minimal (<10 MB/s)
- Network: ~1-10 Mbps for management traffic

## Future Enhancements

### Potential Lab Extensions

**Advanced Scenarios**:
- [ ] Dual VPN tunnels (active/active for load balancing)
- [ ] BGP route filtering and policy-based routing
- [ ] QoS policies for VoIP traffic prioritization
- [ ] IPv6 dual-stack support
- [ ] MPLS L3VPN as alternative to GRE/IPsec

**Automation Opportunities**:
- [ ] Ansible playbook for automated migration
- [ ] Python script for validation test execution
- [ ] Terraform for infrastructure-as-code deployment
- [ ] CI/CD pipeline for lab testing

**Monitoring Improvements**:
- [ ] Prometheus metrics collection
- [ ] Pre-built Grafana dashboards for VPN health
- [ ] Automated alerting for tunnel failures
- [ ] Historical performance trending

**Documentation Enhancements**:
- [ ] Netbox API integration for dynamic documentation
- [ ] Automated network diagram generation
- [ ] Change log tracking in version control
- [ ] Runbook templates for production use

## Conclusion

This lab architecture balances **realism** with **educational value**:

✅ **Realistic**: Mirrors actual enterprise VPN migration scenarios
✅ **Comprehensive**: 16 devices covering routing, security, services, monitoring
✅ **Testable**: 22 validation tests ensure migration success
✅ **Scalable**: Fits on single VPS, supports multiple concurrent users
✅ **Career-Relevant**: Teaches change management and production migration skills

**Technology choices prioritize**:
- Open-source tools (FRR, VyOS, Alpine, Grafana, Netbox)
- Industry-standard protocols (OSPF, BGP, GRE, IPsec)
- Practical skills (zone-based firewalls, IPAM, monitoring)
- Resource efficiency (~2 GB memory, 30-second deployment)

This lab prepares network engineers for real-world migrations where downtime is costly and mistakes are unacceptable.
