# VyOS Firewall Basics Lab

[![Open in GitHub Codespaces](../.github/images/open-in-codespaces.svg)](https://codespaces.new/ciscoittech/containerlab-free-labs?devcontainer_path=vyos-firewall-basics/.devcontainer/devcontainer.json&quickstart=1)

## Overview

Learn basic firewall concepts using VyOS zone-based firewall. This lab teaches the fundamentals of network security with a simple 2-zone model: LAN (trusted) and WAN (untrusted).

**What you'll learn:**
- Zone-based firewall configuration
- Stateful packet inspection
- Default deny security policies
- LAN protection from internet threats

## Topology

```
Internet (WAN)
172.16.10.0/24
      |
  [VyOS Firewall]
      |
     LAN
192.168.100.0/24
      |
   Client1
```

### Network Details

| Zone | Interface | Network | Purpose |
|------|-----------|---------|---------|
| WAN | eth1 | 172.16.10.0/24 | Untrusted internet |
| LAN | eth2 | 192.168.100.0/24 | Trusted internal network |

### Security Policies

| Source | Destination | Policy |
|--------|-------------|--------|
| LAN → WAN | All traffic allowed | Users can access internet |
| WAN → LAN | Blocked (except return traffic) | Internet cannot attack LAN |

## Prerequisites

- **Containerlab** installed
- **Docker** running
- VyOS image: `ghcr.io/sever-sever/vyos-container:latest`
- Alpine image: `alpine:latest`

## Quick Start

### Deploy the Lab

```bash
cd vyos-firewall-basics
containerlab deploy -t topology.clab.yml
```

**Wait 60 seconds** for VyOS to initialize.

### Validate

```bash
./scripts/validate.sh
```

**Expected:** All 5 tests pass ✅

### Access Components

**VyOS Firewall:**
```bash
docker exec -it clab-vyos-firewall-basics-fw1 su - vyos
```

**LAN Client:**
```bash
docker exec -it clab-vyos-firewall-basics-client1 sh
```

**Internet Host:**
```bash
docker exec -it clab-vyos-firewall-basics-internet sh
```

## Learning Objectives

### 1. Understand Zone-Based Firewall

**Zones** group interfaces by trust level:
- **WAN** = Untrusted (internet)
- **LAN** = Trusted (internal network)
- **LOCAL** = Firewall itself

Traffic between zones requires explicit firewall policy.

### 2. Stateful Inspection

The firewall tracks connection state:
- **NEW** = First packet of new connection
- **ESTABLISHED** = Part of existing connection
- **RELATED** = Related to existing connection

**Key benefit:** Allow outbound traffic, automatically allow return traffic.

### 3. Default Deny Policy

**Security best practice:** Deny all traffic by default, explicitly allow needed traffic.

**Example:**
- WAN → LAN: **Drop** (default deny)
- Rule 1: **Accept** established/related (return traffic)
- Result: LAN can browse internet, internet cannot attack LAN

## Hands-On Exercises

### Exercise 1: Test LAN → WAN (Should Work)

Access LAN client:
```bash
docker exec -it clab-vyos-firewall-basics-client1 sh
```

Ping internet:
```bash
ping -c 4 172.16.10.100
```

**Expected:** ✅ Success (LAN can access internet)

### Exercise 2: Test WAN → LAN (Should Fail)

Access internet host:
```bash
docker exec -it clab-vyos-firewall-basics-internet sh
```

Try to ping LAN:
```bash
ping -c 4 -W 2 192.168.100.10
```

**Expected:** ❌ Timeout (internet blocked from LAN)

### Exercise 3: View Firewall Configuration

Access VyOS:
```bash
docker exec -it clab-vyos-firewall-basics-fw1 su - vyos
```

Show zones:
```bash
show firewall zone-policy
```

Show WAN → LAN rules:
```bash
show firewall name wan-lan
```

**Notice:**
- Default action: **drop**
- Rule 1: Allow **established/related**
- Rule 2: Drop **invalid**

### Exercise 4: View Firewall Statistics

```bash
show firewall statistics
```

See how many packets matched each rule.

Clear counters:
```bash
clear firewall statistics
```

Re-run ping tests and check stats again.

## Verification Commands

### Show Zones
```bash
show firewall zone-policy
show firewall zone-policy zone wan
show firewall zone-policy zone lan
```

### Show Rulesets
```bash
show firewall name wan-lan
show firewall name lan-wan
```

### Monitor Traffic
```bash
show firewall statistics
monitor firewall name wan-lan
```

## Troubleshooting

### Lab won't deploy

```bash
# Destroy existing lab
containerlab destroy -t topology.clab.yml --cleanup

# Pull images
docker pull ghcr.io/sever-sever/vyos-container:latest
docker pull alpine:latest

# Redeploy
containerlab deploy -t topology.clab.yml
```

### VyOS not responding

```bash
# Wait 60 seconds for initialization
sleep 60

# Check logs
docker logs clab-vyos-firewall-basics-fw1
```

### Tests fail

```bash
# Verify containers running
docker ps | grep vyos-firewall-basics

# Check VyOS config
docker exec clab-vyos-firewall-basics-fw1 su - vyos -c "show firewall"
```

## Cleanup

```bash
./scripts/cleanup.sh
```

Or manually:
```bash
containerlab destroy -t topology.clab.yml --cleanup
```

## Key Takeaways

✅ **Zone-based firewalls** group interfaces by trust level
✅ **Stateful inspection** automatically allows return traffic
✅ **Default deny** is more secure than default allow
✅ **LAN → WAN** = permissive (trusted users)
✅ **WAN → LAN** = restrictive (untrusted internet)

## Next Steps

Ready for more advanced firewall concepts?

**Upgrade to Lab Pass ($9/month) for:**
- **3-Zone Firewall** - Add DMZ for public services
- **Multi-Zone Security** - Guest networks, VLAN segmentation
- **VPN + Firewall** - IPsec integration
- **Advanced Policies** - NAT, port forwarding, IDS/IPS

Visit: [Your Lab Platform URL]

## Resources

- **VyOS Documentation:** https://docs.vyos.io/en/1.4/
- **Firewall Guide:** https://docs.vyos.io/en/1.4/configuration/firewall/
- **Containerlab:** https://containerlab.dev/

## License

This lab is part of the Free Containerlab Labs project.
Licensed under MIT - see LICENSE file for details.

## Contributing

Found an issue or want to improve this lab?
- Report issues: [GitHub Issues]
- Contribute: See CONTRIBUTING.md
- Community: [Discord/Slack]

---

**Difficulty:** Beginner
**Duration:** 30-45 minutes
**Cost:** Free and open-source
