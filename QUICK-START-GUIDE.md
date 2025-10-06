# Quick Start Guide - Get Your First Lab Running in 5 Minutes

**Goal**: Deploy your first containerized network lab in under 5 minutes

---

## Option 1: VS Code Devcontainer (Recommended)

**Pros**: One-click setup, no local containerlab installation needed, everything just works
**Cons**: Requires VS Code with Remote-Containers extension

### Step 1: Prerequisites
- Install [VS Code](https://code.visualstudio.com/)
- Install [Docker Desktop](https://www.docker.com/products/docker-desktop/)
- Install VS Code extension: **Remote - Containers** (ms-vscode-remote.remote-containers)

### Step 2: Clone Repository
```bash
git clone https://github.com/ciscoittech/containerlab-free-labs.git
cd containerlab-free-labs
```

### Step 3: Open Lab in VS Code
```bash
# Start with Linux Namespaces (easiest, 30 min)
cd linux-network-namespaces
code .
```

### Step 4: Reopen in Container
- VS Code will detect `.devcontainer/devcontainer.json`
- Click **"Reopen in Container"** when prompted
- Wait 2-3 minutes for first-time build (pulls container images)

### Step 5: Deploy Lab
Once inside devcontainer, run:
```bash
./scripts/deploy.sh
```

**Expected output**:
```
=========================================
Deploying Linux Network Namespaces Lab
=========================================

Starting containerlab deployment...
INFO[0000] Containerlab v0.68.0 started
INFO[0001] Parsing & checking topology file: topology.clab.yml
INFO[0002] Creating lab directory: /root/clab-netns-basics
INFO[0003] Creating container: "router"
INFO[0004] Creating container: "client1"
INFO[0005] Creating container: "client2"
INFO[0006] Creating container: "server"
INFO[0010] Created 4 containers

=========================================
Lab Deployed Successfully!
=========================================
```

### Step 6: Validate Lab
```bash
./scripts/validate.sh
```

**Expected output**:
```
=========================================
Linux Network Namespaces Lab - Validation Tests
=========================================

Test 1: Checking IP forwarding on router...
  ✓ PASSED - router has IP forwarding enabled

Test 2: Checking client1 can reach router...
  ✓ PASSED - client1 can ping router (10.0.1.1)

Test 3: Checking client2 can reach router...
  ✓ PASSED - client2 can ping router (10.0.2.1)

Test 4: Checking server can reach router...
  ✓ PASSED - server can ping router (10.0.3.1)

Test 5: Testing cross-subnet routing...
  ✓ PASSED - client1 can reach server (10.0.3.10) through router

=========================================
Validation Summary
=========================================
Tests Passed: 5
Tests Failed: 0

✓ All tests passed! Lab is working correctly.
```

### Step 7: Explore the Lab
```bash
# Access router container
docker exec -it clab-netns-basics-router sh

# Inside container, check network configuration
ip addr show
ip route show
cat /proc/sys/net/ipv4/ip_forward

# Exit container
exit
```

### Step 8: Cleanup
```bash
./scripts/cleanup.sh
```

---

## Option 2: Local Installation (Advanced Users)

**Pros**: Faster for repeated use, no VS Code needed
**Cons**: Requires manual containerlab installation

### Step 1: Install Containerlab
```bash
# Linux/Mac
bash -c "$(curl -sL https://get.containerlab.dev)"

# Verify installation
containerlab version
```

### Step 2: Clone Repository
```bash
git clone https://github.com/ciscoittech/containerlab-free-labs.git
cd containerlab-free-labs/linux-network-namespaces
```

### Step 3: Deploy Lab
```bash
sudo containerlab deploy -t topology.clab.yml
```

### Step 4: Validate
```bash
sudo bash scripts/validate.sh
```

### Step 5: Cleanup
```bash
sudo containerlab destroy -t topology.clab.yml
```

---

## Your First 3 Labs (Suggested Order)

### Lab 1: Linux Network Namespaces (30 min) ⭐
**Why start here**: Understand how containers create isolated networks

**What you'll learn**:
- Network namespaces fundamentals
- Virtual ethernet (veth) pairs
- IP forwarding and routing
- Cross-subnet communication

**Directory**: `linux-network-namespaces/`

**Validation**: 5 automated tests

---

### Lab 2: OSPF Basics (45 min) ⭐⭐
**Why next**: Learn link-state routing with OSPF

**What you'll learn**:
- OSPF neighbor adjacency
- DR/BDR election process
- LSA (Link State Advertisement) flooding
- OSPF route calculation
- Basic troubleshooting

**Directory**: `ospf-basics/`

**Validation**: 6 automated tests

**Topology**:
```
    [R1] ---- [R2] ---- [R3]
     |                   |
     +-------------------+
         (Area 0)
```

---

### Lab 3: BGP eBGP Basics (60 min) ⭐⭐
**Why last**: Understand internet routing with BGP

**What you'll learn**:
- eBGP peering between autonomous systems
- BGP neighbor states (Idle → Established)
- AS-path attribute
- Route advertisement and propagation
- BGP route selection

**Directory**: `bgp-ebgp-basics/`

**Validation**: 6 automated tests

**Topology**:
```
[R1: AS 100] ---- [R2: AS 200] ---- [R3: AS 200]
                                          |
                                    [R4: AS 300]
```

---

## Troubleshooting Common Issues

### Issue 1: "Reopen in Container" button doesn't appear

**Solution**:
```bash
# Check Remote-Containers extension is installed
code --list-extensions | grep ms-vscode-remote.remote-containers

# If not installed:
code --install-extension ms-vscode-remote.remote-containers

# Restart VS Code
```

### Issue 2: Docker not running

**Error**: `Cannot connect to the Docker daemon`

**Solution**:
```bash
# Start Docker Desktop (Mac/Windows)
# Or start Docker service (Linux)
sudo systemctl start docker

# Verify Docker is running
docker ps
```

### Issue 3: Permission denied when running deploy.sh

**Error**: `sudo: a terminal is required to read the password`

**Solution**: You're not inside the devcontainer. Make sure you clicked "Reopen in Container" in VS Code. Check bottom-left corner of VS Code - it should say "Dev Container: <Lab Name>".

### Issue 4: Validation tests fail

**Symptoms**: Some tests show "FAILED" instead of "PASSED"

**Solution**:
```bash
# Give protocols more time to converge
sleep 60

# Run validation again
./scripts/validate.sh

# If still failing, check containers are running
docker ps | grep clab

# Check specific container logs
docker logs clab-<lab-name>-<node-name>
```

### Issue 5: Containers won't start

**Error**: `Error response from daemon: pull access denied`

**Solution**:
```bash
# Manually pull required images
docker pull frrouting/frr:latest
docker pull alpine:latest

# Try deployment again
./scripts/deploy.sh
```

---

## What's Inside Each Lab?

Every lab follows the same structure:

```
<lab-name>/
├── README.md                # Comprehensive lab guide (5KB+)
│   ├── Learning objectives
│   ├── Topology diagram
│   ├── Step-by-step exercises
│   ├── Expected command outputs
│   └── Troubleshooting tips
│
├── topology.clab.yml        # Containerlab topology definition
│   ├── Node definitions
│   ├── Network links
│   └── Configuration binds
│
├── configs/                 # Device configuration files
│   ├── r1/
│   │   ├── daemons         # FRR daemons to enable
│   │   └── frr.conf        # FRR routing configuration
│   ├── r2/
│   └── r3/
│
├── scripts/
│   ├── deploy.sh           # One-command deployment
│   ├── validate.sh         # Automated testing (5-6 tests)
│   └── cleanup.sh          # Clean shutdown
│
└── .devcontainer/
    └── devcontainer.json   # VS Code container config
        ├── Base image: containerlab devcontainer
        ├── Privileged mode enabled
        └── Auto-pull required images
```

---

## Next Steps After Your First Lab

### 1. Complete All 3 Free Labs
- [ ] Linux Network Namespaces (30 min)
- [ ] OSPF Basics (45 min)
- [ ] BGP eBGP Basics (60 min)

**Total time**: ~2.5 hours of hands-on learning

### 2. Experiment and Break Things
- Modify configurations in `configs/`
- Break OSPF/BGP and fix it
- Add more routers to topology
- Create your own test scenarios

### 3. Contribute to the Project
- Found a bug? Open an [issue](https://github.com/ciscoittech/containerlab-free-labs/issues)
- Have an idea? Join the [discussion](https://github.com/ciscoittech/containerlab-free-labs/discussions)
- Want to add a lab? See [CONTRIBUTING.md](CONTRIBUTING.md)

### 4. Explore Advanced Labs (Coming Soon)
- OSPF multi-area configurations
- BGP route reflection and communities
- MPLS L3VPN basics
- SR Linux automation with Python

---

## Performance Benchmarks

**Linux Network Namespaces Lab**:
- Deployment: <20 seconds
- Validation: <3 seconds
- Memory: ~80MB total (4 × 20MB Alpine containers)

**OSPF Basics Lab**:
- Deployment: <30 seconds
- OSPF convergence: 15-30 seconds
- Validation: <5 seconds
- Memory: ~150MB total (3 × 50MB FRR containers)

**BGP eBGP Basics Lab**:
- Deployment: <30 seconds
- BGP convergence: 30-45 seconds
- Validation: <5 seconds
- Memory: ~200MB total (4 × 50MB FRR containers)

**Compare to traditional VM-based labs**:
- GNS3/EVE-NG deployment: 10-15 minutes
- Memory per router: 1GB+ (20x more!)
- Boot time: 5-10 minutes per router

---

## Useful Commands Reference

### Containerlab Commands
```bash
# Deploy lab
sudo containerlab deploy -t topology.clab.yml

# Show lab status
sudo containerlab inspect -t topology.clab.yml

# Save running configs
sudo containerlab save -t topology.clab.yml

# Destroy lab
sudo containerlab destroy -t topology.clab.yml

# List all running labs
sudo containerlab inspect --all
```

### FRR Router Access (OSPF/BGP labs)
```bash
# Access FRR CLI (vtysh)
docker exec -it clab-<lab>-<router> vtysh

# Run single command
docker exec -it clab-<lab>-<router> vtysh -c "show ip ospf neighbor"

# Access bash inside container
docker exec -it clab-<lab>-<router> bash
```

### Alpine Linux Access (Namespaces lab)
```bash
# Access shell
docker exec -it clab-netns-basics-router sh

# Check IP configuration
docker exec -it clab-netns-basics-router ip addr show

# Test ping
docker exec -it clab-netns-basics-client1 ping -c 3 10.0.3.10
```

### Docker Commands
```bash
# List all containers
docker ps

# List lab containers only
docker ps | grep clab

# Check container logs
docker logs clab-<lab>-<node>

# Check container resource usage
docker stats
```

---

## Getting Help

### Documentation
- **Lab-specific README**: Each lab has comprehensive documentation
- **TESTING-INSTRUCTIONS.md**: Detailed testing procedures
- **CONTRIBUTING.md**: How to contribute new labs

### Community
- **GitHub Issues**: Report bugs or request features
- **GitHub Discussions**: Ask questions, share experiences
- **Containerlab Docs**: https://containerlab.dev/
- **FRR Docs**: https://docs.frrouting.org/

### Common Questions

**Q: Can I run multiple labs at the same time?**
A: Yes! Each lab has a unique name, so they won't conflict. Just be mindful of memory usage.

**Q: Will this work on Windows?**
A: Yes, using Docker Desktop + WSL2. The devcontainer approach works great on Windows.

**Q: Can I use this for CCNA/CCNP study?**
A: Absolutely! FRR uses Cisco-like syntax. Perfect for practicing OSPF, BGP, and routing fundamentals.

**Q: Is this really free?**
A: Yes! MIT License. Use for learning, teaching, or building your own projects.

**Q: Where are the advanced labs (MPLS, EVPN)?**
A: Coming soon! These free labs focus on fundamentals. We're planning to add more advanced community-contributed labs. See [CONTRIBUTING.md](CONTRIBUTING.md) if you'd like to help!

---

## Success! What You've Accomplished

After completing this guide, you've:

✅ Deployed your first containerized network lab
✅ Validated it works with automated tests
✅ Understood how containers create isolated networks
✅ Learned the difference between VM-based and container-based labs
✅ Set up a modern network learning environment

**Next**: Complete all 3 labs and start experimenting! 🚀

---

*Last Updated: October 2, 2025*
*Questions? Open an [issue](https://github.com/ciscoittech/containerlab-free-labs/issues)*
