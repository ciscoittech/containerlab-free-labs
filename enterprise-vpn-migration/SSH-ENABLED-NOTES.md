# Enterprise VPN Migration Lab - SSH Enabled ✅

**Date Updated**: 2025-10-06
**Status**: ✅ SSH Access Fully Enabled

---

## What Changed

This lab has been upgraded from standard FRR containers to custom FRR SSH-enabled containers.

### Before (Old)
- ❌ No SSH access to routers
- ❌ Only `docker exec` to access routers
- ❌ Not realistic for enterprise network management
- ❌ Hard to manage 5 routers simultaneously

### After (New) ✅
- ✅ Direct SSH access to all 5 FRR routers
- ✅ Unique SSH ports per router (2231-2235)
- ✅ Realistic enterprise network experience
- ✅ Easy multi-router management
- ✅ Works from code-server/VS Code terminal

---

## SSH Access

| Router | Site | SSH Port | Command |
|--------|------|----------|---------|
| **router-a1** | Chicago Edge | 2231 | `ssh -p 2231 admin@localhost` |
| **router-a2** | Chicago Core | 2232 | `ssh -p 2232 admin@localhost` |
| **router-b1** | Austin Edge | 2233 | `ssh -p 2233 admin@localhost` |
| **router-b2** | Austin Core | 2234 | `ssh -p 2234 admin@localhost` |
| **internet-core** | ISP Backbone | 2235 | `ssh -p 2235 admin@localhost` |

**Credentials**:
- Username: `admin`
- Password: `cisco`

---

## Example Usage

### SSH to router-a1 (Chicago Edge)
```bash
ssh -p 2231 admin@localhost
# Password: cisco

admin@router-a1$ vtysh
router-a1# show ip ospf neighbor
router-a1# show ip bgp summary
router-a1# show ip route
router-a1# ip tunnel show gre0
router-a1# configure terminal
router-a1(config)# router ospf
```

### SSH to router-b1 (Austin Edge - VPN Endpoint)
```bash
ssh -p 2233 admin@localhost

admin@router-b1$ vtysh
router-b1# show ip bgp neighbors
router-b1# show run | section gre
router-b1# ip addr show gre0
```

### SSH to internet-core (ISP Backbone)
```bash
ssh -p 2235 admin@localhost

admin@internet-core$ vtysh
internet-core# show ip bgp summary
internet-core# show ip bgp neighbors 100.64.0.10 advertised-routes
```

---

## Files Modified

1. **`topology.clab.yml`**
   - Changed image from `frrouting/frr:latest` to `frr-ssh:latest` for 5 routers
   - Added SSH port mappings (2231-2235)
   - Added labels for lab metadata (site, router name)
   - Routers updated: router-a1, router-a2, router-b1, router-b2, internet-core

2. **`README.md`**
   - Added Prerequisites section (frr-ssh image requirement)
   - Updated "Accessing Lab Devices" section with comprehensive SSH table
   - Added SSH access example for router-a1
   - Kept docker exec as alternative method

3. **`scripts/deploy.sh`**
   - Updated output to show SSH commands first (recommended method)
   - Added password reminder
   - Added internet-core SSH access
   - Kept docker exec as alternative

---

## Prerequisites

**Must have frr-ssh image built**:
```bash
cd /Users/bhunt/development/claude/sr_linux/labs/.claude-library/docker-images/frr-ssh
docker buildx build --platform linux/amd64 --load -t frr-ssh:latest .
```

Takes ~2 minutes first time, then cached.

---

## Testing

### Quick Test
```bash
# Deploy lab
cd /Users/bhunt/development/claude/containerlab-free-labs/enterprise-vpn-migration
./scripts/deploy.sh

# Wait 30 seconds for services to start (as per deploy.sh)
sleep 30

# Test SSH to router-a1
ssh -p 2231 admin@localhost
# Password: cisco

# Check OSPF
vtysh -c "show ip ospf neighbor"

# Check BGP
vtysh -c "show ip bgp summary"

# Check GRE tunnel
ip tunnel show gre0
```

### Expected Results
- All 5 routers accessible via SSH
- OSPF adjacencies formed (router-a1 ↔ router-a2, router-b1 ↔ router-b2)
- BGP sessions established (router-a1 ↔ internet-core, router-b1 ↔ internet-core)
- GRE tunnel UP (router-a1 ↔ router-b1)
- Can configure routers via SSH terminal
- vtysh commands work correctly

---

## Benefits

✅ **Realistic Enterprise Experience** - SSH to routers like real datacenter gear
✅ **Browser-Friendly** - Works in code-server/GitHub Codespaces terminal
✅ **Multi-Router Management** - Open 5 SSH sessions side-by-side
✅ **VPN Migration Simulation** - Authentic change management experience
✅ **Tool Compatible** - Works with Ansible, Nornir, NetBox automation

---

## Backwards Compatibility

**Docker exec still works**:
```bash
docker exec -it clab-enterprise-vpn-migration-router-a1 vtysh
docker exec -it clab-enterprise-vpn-migration-router-b1 vtysh
docker exec -it clab-enterprise-vpn-migration-internet-core vtysh
```

Both methods are documented in README.md.

---

## Lab Complexity

This is the **largest** and most complex lab with SSH enabled:
- **16 total containers** (5 FRR routers + 2 VyOS firewalls + 9 Alpine hosts/services)
- **2 sites** (Chicago HQ, Austin Remote Office)
- **Multiple technologies**: OSPF, BGP, GRE tunnels, VyOS firewalls
- **Real services**: Web servers, DNS, LDAP, Grafana, Netbox
- **Enterprise scenario**: VPN IP migration with <5 min downtime requirement

Perfect for:
- Network engineers preparing for production changes
- Learning VPN migration strategies (dual-stack, make-before-break)
- Practicing change management and rollback procedures
- Understanding service dependencies in multi-site networks

---

## Next Steps

If deploying for SaaS platform:
1. ✅ SSH access ready for all 5 routers
2. ✅ Port mappings configured (2231-2235)
3. ✅ Documentation updated
4. Consider: Test migration exercises with SSH-based workflow
5. Consider: Create Ansible playbooks using SSH access for automated migration

---

**Status**: ✅ Ready for Production Use

**Lab Type**: Advanced Enterprise
**Difficulty**: ⭐⭐⭐⭐ (4/5 stars)
**Estimated Time**: 2-4 hours
