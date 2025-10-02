## BGP eBGP Basics Lab

**Difficulty**: ⭐⭐ Beginner
**Estimated Time**: 60 minutes
**Prerequisites**: Basic TCP/IP knowledge, OSPF Basics lab recommended

## Lab Objectives

Learn Border Gateway Protocol (BGP) fundamentals with a multi-AS topology:

- ✅ eBGP (External BGP) neighbor establishment
- ✅ BGP route advertisement and propagation
- ✅ AS-path attribute and loop prevention
- ✅ BGP path selection basics
- ✅ Troubleshooting BGP neighbor issues

## Topology

```
AS 100          AS 200          AS 300          AS 100
┌────┐         ┌────┐         ┌────┐         ┌────┐
│ r1 │────────│ r2 │────────│ r3 │────────│ r4 │
└────┘         └────┘         └────┘         └────┘
  .1.1          .2.1           .3.1           .4.1
```

### AS Design

- **AS 100**: r1 (192.168.1.0/24) and r4 (192.168.4.0/24)
- **AS 200**: r2 (192.168.2.0/24) - Transit AS
- **AS 300**: r3 (192.168.3.0/24)

### Router Details

| Router | AS  | Router ID | Loopback      | Neighbors |
|--------|-----|-----------|---------------|-----------|
| r1     | 100 | 1.1.1.1   | 192.168.1.1/24 | r2 (AS 200) |
| r2     | 200 | 2.2.2.2   | 192.168.2.1/24 | r1 (AS 100), r3 (AS 300) |
| r3     | 300 | 3.3.3.3   | 192.168.3.1/24 | r2 (AS 200), r4 (AS 100) |
| r4     | 100 | 4.4.4.4   | 192.168.4.1/24 | r3 (AS 300) |

## Quick Start

### Option 1: VS Code Devcontainer (Recommended)

```bash
cd bgp-ebgp-basics
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
cd bgp-ebgp-basics
sudo containerlab deploy -t topology.clab.yml

# Access router CLI
docker exec -it clab-bgp-ebgp-basics-r1 vtysh

# Run validation
./scripts/validate.sh

# Cleanup
sudo containerlab destroy -t topology.clab.yml
```

## Lab Exercises

### Exercise 1: Verify BGP Neighbors

Access r2 (the transit AS) and check BGP neighbors:

```bash
docker exec -it clab-bgp-ebgp-basics-r2 vtysh
```

Inside vtysh:
```
show ip bgp summary
```

**Expected Output**: 2 neighbors in **Established** state (AS 100 and AS 300).

**Questions**:
- What TCP port does BGP use?
- What is the BGP state machine sequence?
- Why is r2's BGP session with r1 called "eBGP"?

### Exercise 2: View BGP Routes

On r1, view all BGP routes:

```
show ip bgp
```

**Expected Output**: You should see routes to:
- 192.168.1.0/24 (own network)
- 192.168.2.0/24 (via AS 200)
- 192.168.3.0/24 (via AS 200, AS 300)
- 192.168.4.0/24 (via AS 200, AS 300, AS 100)

**Questions**:
- What is the AS-path for 192.168.3.0/24?
- Why doesn't r1 accept the route to 192.168.4.0/24 with AS-path "200 300 100"?
- How does BGP prevent routing loops?

### Exercise 3: AS-Path Analysis

Check the AS-path for routes on r1:

```
show ip bgp 192.168.3.0/24
```

**Expected AS-path**: `200 300`

Now check r4's AS-path to 192.168.2.0/24:

```bash
docker exec -it clab-bgp-ebgp-basics-r4 vtysh -c "show ip bgp 192.168.2.0/24"
```

**Expected AS-path**: `300 200`

**Questions**:
- Why is the AS-path different for r1 and r4?
- What happens if you add AS 100 to the AS-path for a route going to r1?

### Exercise 4: BGP Attributes

View detailed BGP attributes:

```
show ip bgp 192.168.2.0/24
```

Look for:
- **Next-hop**: IP address of the next router
- **AS-path**: Sequence of AS numbers
- **Origin**: IGP, EGP, or Incomplete
- **Local Preference**: (iBGP only, not visible in eBGP)

**Questions**:
- What is the next-hop for 192.168.2.0/24 from r1's perspective?
- Why is the next-hop NOT r2's loopback address?

### Exercise 5: BGP Path Selection

On r4, check which path is preferred to reach 192.168.1.0/24:

```bash
docker exec -it clab-bgp-ebgp-basics-r4 vtysh -c "show ip bgp 192.168.1.0/24"
```

**Expected**: Only one path via AS 300, AS 200, AS 100 (AS-path: `300 200`)

**Note**: In this topology, there's only one path. In a real scenario with multiple paths, BGP uses the **shortest AS-path** as a tiebreaker.

### Exercise 6: Break and Fix (Troubleshooting)

On r2, shutdown the BGP session to r1:

```bash
docker exec -it clab-bgp-ebgp-basics-r2 vtysh
```

```
configure terminal
router bgp 200
 no neighbor 10.1.1.1
end
```

Now check r1's BGP status:

```bash
docker exec -it clab-bgp-ebgp-basics-r1 vtysh -c "show ip bgp summary"
```

**Expected**: No BGP neighbor or neighbor in **Idle** state.

**Fix it**: Re-add the neighbor on r2:

```
configure terminal
router bgp 200
 neighbor 10.1.1.1 remote-as 100
 address-family ipv4 unicast
  neighbor 10.1.1.1 activate
 exit-address-family
end
```

Wait 30 seconds and check again - the session should re-establish.

## Validation Tests

Run automated validation:

```bash
./scripts/validate.sh
```

**Expected Results**: 6/6 tests passed

Tests verify:
1. r1 has established BGP session with AS 200
2. r2 has 2 established BGP sessions (AS 100 and AS 300)
3. r1 learned at least 3 BGP routes
4. r4 learned route to 192.168.3.0/24 (AS 300)
5. r1 sees correct AS-path for AS 300 routes
6. Connectivity test (r1 can ping r3's loopback)

## Key BGP Commands

| Command | Description |
|---------|-------------|
| `show ip bgp summary` | View all BGP neighbors and their status |
| `show ip bgp` | View BGP routing table |
| `show ip bgp neighbors` | Detailed neighbor information |
| `show ip bgp <prefix>` | Detailed info for specific prefix |
| `show ip route bgp` | View only BGP routes in main routing table |
| `clear ip bgp *` | Reset all BGP sessions (be careful!) |

## Common Issues

### BGP neighbor stuck in Active/Connect

**Possible causes**:
- TCP connection cannot be established (firewall, routing issue)
- Wrong neighbor IP address
- No route to neighbor

**Check**:
```
show ip bgp neighbors <neighbor-ip>
ping <neighbor-ip>
```

### Routes not being advertised

**Possible causes**:
- Network not added to BGP with `network` command
- Route not in RIB (routing table)
- BGP filters blocking advertisement

**Check**:
```
show ip route <prefix>
show running-config
```

### AS-path loop prevention

BGP will **reject** any route where its own AS number appears in the AS-path. This prevents routing loops.

**Example**: r1 (AS 100) will reject routes with AS-path containing `100`.

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
- **iBGP Internal BGP** (Premium lab) - Learn iBGP full-mesh and route reflection
- **BGP Route Reflection** (Premium lab) - Reduce iBGP mesh complexity
- **BGP Communities** (Premium lab) - Advanced route tagging and filtering

## Resources

- [BGP RFC 4271](https://www.rfc-editor.org/rfc/rfc4271)
- [FRRouting BGP Documentation](https://docs.frrouting.org/en/latest/bgp.html)
- [BGP Best Practices](https://www.cisco.com/c/en/us/support/docs/ip/border-gateway-protocol-bgp/13753-25.html)

---

**Want more advanced labs?** Check out our premium platform with iBGP, MPLS L3VPN, SR Linux automation, and more!
