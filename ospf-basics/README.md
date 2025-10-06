# OSPF Basics Lab

[![Open in GitHub Codespaces](../.github/images/open-in-codespaces.svg)](https://codespaces.new/ciscoittech/containerlab-free-labs?devcontainer_path=ospf-basics/.devcontainer/devcontainer.json)

**Difficulty**: ⭐⭐ Beginner
**Estimated Time**: 45 minutes
**Prerequisites**: Basic networking knowledge

## Lab Objectives

Learn OSPF (Open Shortest Path First) fundamentals with a simple 3-router topology:

- ✅ OSPF neighbor adjacency formation
- ✅ OSPF single-area (Area 0) configuration
- ✅ OSPF route advertisement and learning
- ✅ DR/BDR election on broadcast networks
- ✅ Basic OSPF troubleshooting commands

## Topology

```
           10.0.1.0/24              10.0.3.0/24
    r1 ─────────────── r2 ───────────────── r3
     │                                      │
     └──────────────────────────────────────┘
               10.0.2.0/24

r3 also has a "simulated LAN": 192.168.100.0/24
```

### Router Details

| Router | Router ID | Interfaces |
|--------|-----------|------------|
| r1     | 1.1.1.1   | eth1: 10.0.1.1/24, eth2: 10.0.2.1/24 |
| r2     | 2.2.2.2   | eth1: 10.0.1.2/24, eth2: 10.0.3.2/24 |
| r3     | 3.3.3.3   | eth1: 10.0.2.3/24, eth2: 10.0.3.3/24, eth3: 192.168.100.1/24 |

## Quick Start

### Option 1: VS Code Devcontainer (Recommended)

```bash
cd ospf-basics
code .
# Click "Reopen in Container" when prompted
```

Once inside the devcontainer:
```bash
./scripts/deploy.sh
./scripts/validate.sh
```

### Option 2: Local Deployment

```bash
cd ospf-basics
sudo containerlab deploy -t topology.clab.yml

# Access router CLI
docker exec -it clab-ospf-basics-r1 vtysh

# Run validation
./scripts/validate.sh

# Cleanup
sudo containerlab destroy -t topology.clab.yml
```

## Accessing Lab Devices

✨ **NEW**: This lab now uses custom FRR SSH image for direct SSH access to routers!

### SSH Access to Routers (Recommended)

Each router has SSH enabled on a unique host port:

| Router | SSH Port | SSH Command |
|--------|----------|-------------|
| **r1** | 2221 | `ssh -p 2221 cisco@localhost` |
| **r2** | 2222 | `ssh -p 2222 cisco@localhost` |
| **r3** | 2223 | `ssh -p 2223 cisco@localhost` |

**Credentials**:
- Username: `cisco`
- Password: `cisco`

**Example - SSH to r1**:
```bash
ssh -p 2221 cisco@localhost
# Password: cisco

admin@r1$ vtysh
r1# show ip ospf neighbor
r1# show ip route
```

### Alternative: Docker Exec Access

**Interactive mode** (Cisco-like CLI):
```bash
docker exec -it clab-ospf-basics-r1 vtysh
```

**Run single command**:
```bash
docker exec clab-ospf-basics-r1 vtysh -c "show ip ospf neighbor"
```

**Access bash shell** (for debugging):
```bash
docker exec -it clab-ospf-basics-r1 bash
```

### Common Commands

| Task | Command (via SSH) |
|------|-------------------|
| Check OSPF neighbors | `vtysh -c "show ip ospf neighbor"` |
| View OSPF routes | `vtysh -c "show ip route ospf"` |
| Check OSPF database | `vtysh -c "show ip ospf database"` |
| View routing table | `vtysh -c "show ip route"` |
| Show configuration | `vtysh -c "show run"` |

**Why no SSH?**
- ✅ Faster container startup (no SSH daemon)
- ✅ Smaller container images (50MB vs 200MB+)
- ✅ More secure (no SSH attack surface)
- ✅ Standard practice for containerized labs

## Lab Exercises

### Exercise 1: Verify OSPF Neighbors

Access r1 and check OSPF neighbors:

```bash
docker exec -it clab-ospf-basics-r1 vtysh
```

Inside vtysh:
```
show ip ospf neighbor
```

**Expected Output**: You should see 2 neighbors (r2 and r3) in **Full** state.

**Questions**:
- What is the DR (Designated Router) for network 10.0.1.0/24?
- Why does OSPF need a DR on broadcast networks?

### Exercise 2: View OSPF Routes

Check the routing table on r1:

```
show ip route ospf
```

**Expected Output**: Routes to 10.0.3.0/24 and 192.168.100.0/24 learned via OSPF.

**Questions**:
- What is the cost to reach 192.168.100.0/24 from r1?
- How does OSPF calculate the cost?

### Exercise 3: View OSPF Database

Check the OSPF Link State Database:

```
show ip ospf database
```

**Expected Output**: LSAs (Link State Advertisements) from all 3 routers.

**Questions**:
- How many Router LSAs do you see?
- What is an LSA Type 1?

### Exercise 4: Test Connectivity

From r1, ping the simulated LAN on r3:

```bash
docker exec clab-ospf-basics-r1 ping 192.168.100.1 -c 3
```

**Expected Output**: Successful pings.

**Questions**:
- Trace the path packets take from r1 to 192.168.100.1
- What would happen if the link between r1 and r2 failed?

### Exercise 5: Break Something (Troubleshooting)

On r2, shutdown OSPF on interface eth1:

```bash
docker exec -it clab-ospf-basics-r2 vtysh
```

```
configure terminal
interface eth1
 no ip ospf area 0
end
```

Now check r1's OSPF neighbors again:

```bash
docker exec -it clab-ospf-basics-r1 vtysh -c "show ip ospf neighbor"
```

**Expected**: r2 should be missing from r1's neighbor table.

**Fix it**: Re-enable OSPF on r2's eth1:

```
configure terminal
interface eth1
 ip ospf area 0
end
```

## Validation Tests

Run automated validation:

```bash
./scripts/validate.sh
```

**Expected Results**: 6/6 tests passed

Tests verify:
1. r1 has 2 OSPF neighbors in Full state
2. r2 has 2 OSPF neighbors in Full state
3. r3 has 2 OSPF neighbors in Full state
4. r1 learned route to 192.168.100.0/24
5. r2 learned route to 192.168.100.0/24
6. Connectivity test (r1 can ping 192.168.100.1)

## Key OSPF Commands

| Command | Description |
|---------|-------------|
| `show ip ospf neighbor` | View OSPF neighbors and their states |
| `show ip ospf interface` | View OSPF-enabled interfaces |
| `show ip ospf database` | View OSPF Link State Database (LSDB) |
| `show ip route ospf` | View only OSPF routes |
| `show ip ospf border-routers` | View ABRs (Area Border Routers) |

## Common Issues

### OSPF neighbors stuck in Init/2-Way

**Possible causes**:
- MTU mismatch
- Hello/Dead interval mismatch
- Network type mismatch (broadcast vs point-to-point)

**Check**:
```
show ip ospf interface eth1
```

### Routes not appearing

**Possible causes**:
- Interface not in OSPF area
- Interface is passive

**Check**:
```
show ip ospf interface
show running-config
```

## Cleanup

```bash
./scripts/cleanup.sh
```

Or manually:
```bash
sudo containerlab destroy -t topology.clab.yml
```

## Next Steps

After completing this lab, try:
- **BGP eBGP Basics** - Learn internet routing with BGP
- **Linux Network Namespaces** - Understand container networking fundamentals

## Resources

- [OSPF RFC 2328](https://www.rfc-editor.org/rfc/rfc2328)
- [FRRouting OSPF Documentation](https://docs.frrouting.org/en/latest/ospfd.html)
- [Containerlab Documentation](https://containerlab.dev/)
