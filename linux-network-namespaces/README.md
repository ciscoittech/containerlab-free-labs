# Linux Network Namespaces Lab

[![Open in GitHub Codespaces](../.github/images/open-in-codespaces.svg)](https://codespaces.new/ciscoittech/containerlab-free-labs?devcontainer_path=linux-network-namespaces/.devcontainer/devcontainer.json)

**Difficulty**: ⭐ Beginner
**Estimated Time**: 30 minutes
**Prerequisites**: Basic Linux command line knowledge

## Lab Objectives

Understand how network namespaces work - the foundation of containerlab and Docker networking:

- ✅ What are Linux network namespaces?
- ✅ How containers get isolated networking
- ✅ Virtual Ethernet (veth) pairs
- ✅ Basic IP routing between namespaces
- ✅ How containerlab creates network topologies

## Topology

```
    10.0.1.0/24              10.0.2.0/24
┌────────┐ ┌────────┐     ┌────────┐
│ host1  │─┤ host2  │     │ host3  │
│  .10   │ │  .20   │     │  .10   │
└────────┘ └────────┘     └────────┘
     │         │               │
     └────┬────┘               │
          │                    │
      ┌───┴────┐          ┌────┴───┐
      │ router │──────────│ router │
      │  .1    │          │  .1    │
      └────────┘          └────────┘
```

### Container Details

| Container | IP Address     | Role |
|-----------|---------------|------|
| host1     | 10.0.1.10/24  | End host on LAN 1 |
| host2     | 10.0.1.20/24  | End host on LAN 1 |
| router    | 10.0.1.1/24, 10.0.2.1/24 | Router between subnets |
| host3     | 10.0.2.10/24  | End host on LAN 2 |

## Quick Start

### Option 1: VS Code Devcontainer (Recommended)

```bash
cd linux-network-namespaces
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
cd linux-network-namespaces
sudo containerlab deploy -t topology.clab.yml

# Access containers
docker exec -it clab-netns-basics-host1 sh

# Run validation
./scripts/validate.sh

# Cleanup
sudo containerlab destroy -t topology.clab.yml
```

## Lab Exercises

### Exercise 1: Understanding Network Namespaces

**What are network namespaces?**

Linux network namespaces provide isolated network stacks. Each namespace has:
- Its own network interfaces
- Its own IP addresses
- Its own routing table
- Its own firewall rules

**How do containers use namespaces?**

When containerlab (or Docker) creates a container, it:
1. Creates a new network namespace
2. Creates a virtual Ethernet (veth) pair
3. Puts one end in the container's namespace
4. Puts the other end on the host or in another namespace

### Exercise 2: Explore a Container's Network Namespace

Access host1:

```bash
docker exec -it clab-netns-basics-host1 sh
```

Inside the container, check the network interfaces:

```bash
ip addr show
```

**Expected Output**:
- `lo` - Loopback interface
- `eth1` - Virtual Ethernet interface connected to router

Check the routing table:

```bash
ip route show
```

**Questions**:
- What is the default gateway?
- Why is there a route to 10.0.1.0/24?

### Exercise 3: Virtual Ethernet (veth) Pairs

From the **host machine** (not inside a container), find the veth pairs:

```bash
# On Mac, this won't work directly - use Linux VM or devcontainer
docker network inspect bridge
```

**In the devcontainer**:

```bash
ip link show type veth
```

**Expected**: Multiple veth pairs created by containerlab.

**How it works**:
- veth pairs are like a virtual cable
- One end is in the container (e.g., `eth1`)
- Other end is on the host or in another container
- Packets sent to one end appear on the other end

### Exercise 4: Test Connectivity

From host1, ping other hosts:

```bash
docker exec clab-netns-basics-host1 ping -c 3 10.0.1.20  # host2
docker exec clab-netns-basics-host1 ping -c 3 10.0.1.1   # router
docker exec clab-netns-basics-host1 ping -c 3 10.0.2.10  # host3
```

**Questions**:
- Why can host1 ping host2 directly?
- Why does host1 need the router to reach host3?

### Exercise 5: IP Forwarding on the Router

Check if IP forwarding is enabled on the router:

```bash
docker exec clab-netns-basics-router sysctl net.ipv4.ip_forward
```

**Expected Output**: `net.ipv4.ip_forward = 1`

**What does this do?**

IP forwarding allows the router to forward packets between different subnets. Without it, packets from host1 destined for host3 would be dropped.

Try disabling it:

```bash
docker exec clab-netns-basics-router sysctl -w net.ipv4.ip_forward=0
```

Now try to ping host3 from host1:

```bash
docker exec clab-netns-basics-host1 ping -c 2 10.0.2.10
```

**Expected**: Ping fails!

Re-enable forwarding:

```bash
docker exec clab-netns-basics-router sysctl -w net.ipv4.ip_forward=1
```

### Exercise 6: Routing Tables

On host3, check the routing table:

```bash
docker exec clab-netns-basics-host3 ip route show
```

**Expected Output**:
```
10.0.1.0/24 via 10.0.2.1 dev eth1
10.0.2.0/24 dev eth1 scope link
```

**Explanation**:
- Direct route to 10.0.2.0/24 (local subnet)
- Route to 10.0.1.0/24 via router (10.0.2.1)

**Questions**:
- What happens if you delete the route to 10.0.1.0/24?
- How does host3 know to send packets to the router?

### Exercise 7: Packet Capture

Capture packets on host1's eth1 interface:

```bash
docker exec clab-netns-basics-host1 sh -c "apk add tcpdump && tcpdump -i eth1 -c 5"
```

While tcpdump is running, from another terminal ping the router:

```bash
docker exec clab-netns-basics-host1 ping -c 3 10.0.1.1
```

**Expected Output**: ICMP echo request and reply packets.

**Questions**:
- What is the source and destination MAC address?
- Why do you see both request and reply?

## Validation Tests

Run automated validation:

```bash
./scripts/validate.sh
```

**Expected Results**: 5/5 tests passed

Tests verify:
1. host1 can ping router (10.0.1.1)
2. host2 can ping router (10.0.1.1)
3. host1 and host2 can ping each other (same subnet)
4. IP forwarding enabled on router
5. host1 can ping host3 (10.0.2.10) via router

## Key Linux Networking Commands

| Command | Description |
|---------|-------------|
| `ip addr show` | Show IP addresses on all interfaces |
| `ip route show` | Show routing table |
| `ip link show` | Show network interfaces |
| `ping <ip>` | Test connectivity to another host |
| `traceroute <ip>` | Show path packets take (not in Alpine by default) |
| `tcpdump -i <interface>` | Capture packets on interface |
| `sysctl net.ipv4.ip_forward` | Check/set IP forwarding |

## How Containerlab Uses This

Containerlab creates network topologies by:

1. **Creating containers**: Each node becomes a separate network namespace
2. **Creating veth pairs**: Virtual cables connecting containers
3. **Configuring IPs**: Assigning IP addresses to interfaces
4. **Setting up routing**: Configuring routing between subnets (if needed)

**Why is this powerful?**

- **Lightweight**: No VMs needed, just Linux namespaces
- **Fast**: Containers start in seconds vs minutes for VMs
- **Flexible**: Can create complex topologies easily
- **Portable**: Works on any Linux system with Docker

## Common Issues

### Cannot ping between containers

**Possible causes**:
- IP addresses not configured
- No route to destination
- Firewall blocking packets

**Check**:
```bash
docker exec <container> ip addr show
docker exec <container> ip route show
```

### IP forwarding not working

**Possible causes**:
- `net.ipv4.ip_forward = 0` on router
- No default route on end hosts

**Fix**:
```bash
docker exec <router> sysctl -w net.ipv4.ip_forward=1
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

Now that you understand network namespaces, try:
- **OSPF Basics** - Learn routing protocols using FRR routers
- **BGP eBGP Basics** - Learn internet routing with BGP
- Build your own topology with containerlab!

## Resources

- [Linux Network Namespaces](https://man7.org/linux/man-pages/man7/network_namespaces.7.html)
- [Containerlab Documentation](https://containerlab.dev/)
- [Understanding veth Pairs](https://man7.org/linux/man-pages/man4/veth.4.html)
