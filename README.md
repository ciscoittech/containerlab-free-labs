# Free Containerlab Network Labs 🚀

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![Labs](https://img.shields.io/badge/labs-6-blue.svg)](.)
[![Containerlab](https://img.shields.io/badge/containerlab-latest-green.svg)](https://containerlab.dev/)
[![CI](https://github.com/ciscoittech/containerlab-free-labs/workflows/Validate%20Labs/badge.svg)](https://github.com/ciscoittech/containerlab-free-labs/actions)

**Modern, lightweight network labs using Containerlab and FRR routing**

[![Run in Codespaces](.github/images/open-in-codespaces.svg)](https://codespaces.new/ciscoittech/containerlab-free-labs?quickstart=1)

> Learn OSPF, BGP, and Linux networking with hands-on containerized labs. No VMs required!

## Why Containerlab?

Traditional network labs (GNS3, EVE-NG) require heavy virtual machines and complex setup. These containerized labs offer:

- ✅ **75% less memory** - ~50MB per router vs 1GB+ for VM-based labs
- ✅ **96% faster startup** - 30 seconds vs 10+ minutes
- ✅ **Zero configuration** - One-click deployment with VS Code devcontainers
- ✅ **Modern approach** - Docker containers, not VMs

## 🎓 Available Labs

| Lab | Difficulty | Time | Topics | Tests |
|-----|-----------|------|--------|-------|
| [**OSPF Basics**](ospf-basics/) | ⭐⭐ Beginner | 45 min | OSPF single-area, neighbor adjacency, DR/BDR election | 6 |
| [**BGP eBGP Basics**](bgp-ebgp-basics/) | ⭐⭐ Beginner | 60 min | eBGP peering, AS-path, route advertisement | 6 |
| [**Linux Network Namespaces**](linux-network-namespaces/) | ⭐ Beginner | 30 min | Network namespaces, veth pairs, IP forwarding | 5 |
| [**VyOS Firewall Basics**](vyos-firewall-basics/) | ⭐⭐ Beginner | 45 min | Zone-based firewall, NAT, traffic filtering | 5 |
| [**Enterprise VPN Migration**](enterprise-vpn-migration/) | ⭐⭐⭐ Advanced | 90 min | GRE tunnels, OSPF+BGP, site-to-site VPN, migration runbook | 22 |
| [**Zero Trust Fundamentals**](zero-trust-fundamentals/) | ⭐⭐ Intermediate | 45 min | JWT auth, microservices, identity-based access control | 5 |

### 1. OSPF Basics
Learn OSPF fundamentals with a simple 3-router topology. Perfect for understanding OSPF operation, DR/BDR election, and basic troubleshooting.

[**→ Start OSPF Lab**](ospf-basics/)

### 2. BGP eBGP Basics
Understand external BGP with a 4-router, 3-AS topology. Learn BGP neighbor establishment, route propagation, and AS-path manipulation.

[**→ Start BGP Lab**](bgp-ebgp-basics/)

### 3. Linux Network Namespaces
Explore how containerlab uses Linux network namespaces to create isolated network environments. Understand the foundation of container networking.

[**→ Start Linux Namespaces Lab**](linux-network-namespaces/)

### 4. VyOS Firewall Basics
Configure zone-based firewall policies using VyOS. Learn traffic filtering, NAT, and network segmentation fundamentals.

[**→ Start VyOS Firewall Lab**](vyos-firewall-basics/)

### 5. Enterprise VPN Migration
Tackle a real-world scenario: migrate a site-to-site GRE VPN between two offices with minimal downtime. Includes 16 containers across 2 sites with OSPF, BGP, firewalls, and application services.

[**→ Start Enterprise VPN Lab**](enterprise-vpn-migration/)

### 6. Zero Trust Fundamentals
Build and explore a zero-trust microservices architecture with JWT authentication, identity verification, and protected API endpoints.

[**→ Start Zero Trust Lab**](zero-trust-fundamentals/)

## ✨ SSH Access to Routers

All labs include **SSH access with auto-login to router CLI** - just like real Cisco/Juniper routers!

**Credentials:**
- Username: `admin`
- Password: `cisco`

**Access methods:**
1. **VS Code Extension** (easiest) - Right-click container → SSH
2. **Port mapping** - `ssh -p 2221 admin@localhost`
3. **Container name** - `ssh admin@clab-ospf-basics-r1`

**You land directly at the router CLI:**
```
$ ssh -p 2221 admin@localhost
Password: cisco

r1#  ← Router CLI (not bash shell!)
r1# show ip ospf neighbor
r1# show ip route
```

See [SSH-SETUP-COMPLETE.md](SSH-SETUP-COMPLETE.md) for complete documentation.

## 🚀 Quick Start

### Prerequisites

```bash
# Install containerlab (Linux/Mac)
bash -c "$(curl -sL https://get.containerlab.dev)"

# Verify installation
containerlab version
```

### Run a Lab

```bash
# Clone this repo
git clone https://github.com/ciscoittech/containerlab-free-labs.git
cd containerlab-free-labs

# Build frr-ssh image (first time only)
./build-frr-ssh.sh

# Option 1: Run in VS Code with devcontainer (recommended)
cd ospf-basics
code .  # Click "Reopen in Container"

# Option 2: Run locally
cd ospf-basics
sudo containerlab deploy -t topology.clab.yml

# Access routers via SSH (recommended)
ssh -p 2221 admin@localhost  # OSPF r1
# Password: cisco
# Lands directly at router CLI: r1#

# Alternative: Docker exec
docker exec -it clab-ospf-basics-r1 vtysh

# Cleanup
sudo containerlab destroy -t topology.clab.yml
```

## 📚 Learning Path

1. **Start here**: Linux Network Namespaces (understand the foundation)
2. **OSPF Basics**: Learn link-state routing protocols
3. **BGP eBGP Basics**: Understand internet routing fundamentals
4. **VyOS Firewall Basics**: Add security with zone-based firewalls
5. **Zero Trust Fundamentals**: Explore identity-based access control
6. **Enterprise VPN Migration**: Put it all together in a real-world scenario

## 🤝 Contributing

Contributions are welcome! See [CONTRIBUTING.md](CONTRIBUTING.md) for guidelines.

**Quick start**:
1. Fork this repo
2. Create a feature branch (`git checkout -b feature/new-lab`)
3. Test in devcontainer (`./scripts/validate.sh`)
4. Submit a PR

**Want to add a lab?** Check our [lab template](CONTRIBUTING.md#contributing-new-labs)

## 📖 Resources

- [Containerlab Documentation](https://containerlab.dev/)
- [FRRouting Documentation](https://docs.frrouting.org/)
- [Network Automation Community](https://networkautomation.forum/)

## 📜 License

MIT License - Use these labs for learning, teaching, or building your own projects!

---

**Note**: These labs use FRR (Free Range Routing) which provides Cisco-like syntax for BGP, OSPF, IS-IS, and more. Perfect for CCNA/CCNP lab practice without expensive hardware!
