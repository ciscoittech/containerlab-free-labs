# BGP eBGP Basics Lab - Troubleshooting Guide

This guide covers common issues you may encounter in the BGP eBGP Basics lab.

---

## Container and Access Issues

### Issue: Cannot SSH to routers

**Symptom**:
- `ssh admin@<container-ip>` connection refused or timeout
- Cannot use SSH client to access router CLI
- Error: "Connection refused" or "No route to host"

**Cause**:
FRR containers (`frrouting/frr:latest`) do not include SSH server by default. This is **intentional** - containers are designed for single-process execution and SSH adds unnecessary complexity.

**Solution** - Use `docker exec` instead:

```bash
# Access router r1 CLI (interactive vtysh)
docker exec -it clab-bgp-ebgp-basics-r1 vtysh

# Run BGP commands directly
docker exec clab-bgp-ebgp-basics-r1 vtysh -c "show ip bgp summary"
docker exec clab-bgp-ebgp-basics-r1 vtysh -c "show ip bgp"
docker exec clab-bgp-ebgp-basics-r1 vtysh -c "show ip bgp neighbors"

# Access bash shell (for advanced debugging)
docker exec -it clab-bgp-ebgp-basics-r1 bash
```

**Why This Is Better**:
- ✅ Faster container startup (no SSH daemon to initialize)
- ✅ Smaller container images (50MB vs 200MB+ with SSH)
- ✅ More secure (no SSH attack surface)
- ✅ Standard practice for containerized network labs
- ✅ Works in GitHub Codespaces (no root access required)

**Alternative** (NOT recommended for labs):
If you absolutely need SSH for a specific use case, you can add openssh-server in `topology.clab.yml`:

```yaml
nodes:
  r1:
    exec:
      - apt-get update && apt-get install -y openssh-server
      - echo 'root:cisco' | chpasswd
      - service ssh start
```

**Trade-offs**:
- ❌ Adds 30-60 seconds to container startup
- ❌ Increases image size by 150MB per router
- ❌ Requires maintaining SSH credentials
- ❌ Not portable to GitHub Codespaces
- ❌ Breaks container best practices

---

## BGP Neighbor Issues

### Issue: BGP neighbor stuck in Active/Connect state

**Symptom**:
```
show ip bgp summary
Neighbor        V         AS MsgRcvd MsgSent   TblVer  InQ OutQ  Up/Down State/PfxRcd
10.1.1.2        4        200       0       0        0    0    0 never    Active
```

**Possible Causes**:
1. TCP connection cannot be established (routing issue, firewall)
2. Wrong neighbor IP address configured
3. No route to neighbor's IP
4. Interface is DOWN

**Debugging Steps**:

```bash
# Check BGP neighbor details
docker exec clab-bgp-ebgp-basics-r1 vtysh -c "show ip bgp neighbors 10.1.1.2"

# Test connectivity to neighbor
docker exec clab-bgp-ebgp-basics-r1 ping -c 3 10.1.1.2

# Check routing table
docker exec clab-bgp-ebgp-basics-r1 vtysh -c "show ip route"

# Check interface status
docker exec clab-bgp-ebgp-basics-r1 ip link show
```

**Solution**:
1. Verify neighbor IP is correct in configuration
2. Ensure interface between routers is UP
3. Check that routing allows TCP connection (BGP uses TCP port 179)

---

### Issue: BGP neighbor stuck in Idle state

**Symptom**:
```
Neighbor        V         AS MsgRcvd MsgSent   TblVer  InQ OutQ  Up/Down State/PfxRcd
10.1.1.2        4        200       0       0        0    0    0 never    Idle
```

**Possible Causes**:
1. BGP process not started
2. Neighbor configuration missing
3. BGP waiting for retry timer
4. Administrative shutdown

**Debugging Steps**:

```bash
# Check if BGP is configured
docker exec clab-bgp-ebgp-basics-r1 vtysh -c "show run" | grep -A 10 "router bgp"

# Check BGP process status
docker exec clab-bgp-ebgp-basics-r1 vtysh -c "show ip bgp neighbors 10.1.1.2" | grep "BGP state"

# Check for administrative shutdown
docker exec clab-bgp-ebgp-basics-r1 vtysh -c "show ip bgp neighbors 10.1.1.2" | grep "shutdown"
```

**Solution**:
```bash
# Restart BGP session
docker exec clab-bgp-ebgp-basics-r1 vtysh -c "clear ip bgp 10.1.1.2"

# Or restart all BGP sessions
docker exec clab-bgp-ebgp-basics-r1 vtysh -c "clear ip bgp *"
```

---

### Issue: BGP session established but no routes received

**Symptom**:
```
Neighbor        V         AS MsgRcvd MsgSent   TblVer  InQ OutQ  Up/Down State/PfxRcd
10.1.1.2        4        200      10      15        0    0    0 00:05:23        0
```
(PfxRcd = 0 means no routes received)

**Possible Causes**:
1. Neighbor is not advertising any routes
2. Address-family not activated
3. BGP filters blocking routes

**Debugging Steps**:

```bash
# Check if address-family is activated
docker exec clab-bgp-ebgp-basics-r1 vtysh -c "show run" | grep -A 20 "router bgp"

# Check what neighbor is sending (from neighbor's perspective)
docker exec clab-bgp-ebgp-basics-r2 vtysh -c "show ip bgp neighbors 10.1.1.1 advertised-routes"

# Check for route-maps or filters
docker exec clab-bgp-ebgp-basics-r1 vtysh -c "show ip bgp neighbors 10.1.1.2" | grep "route-map\|filter"
```

**Solution**:
Ensure address-family is activated on both routers:

```bash
docker exec clab-bgp-ebgp-basics-r1 vtysh
```

```
configure terminal
router bgp 100
 address-family ipv4 unicast
  neighbor 10.1.1.2 activate
 exit-address-family
end
```

---

## Route Advertisement Issues

### Issue: Routes not being advertised to BGP neighbors

**Symptom**:
Routes exist in routing table but are not in BGP table or not advertised to neighbors.

**Possible Causes**:
1. Network not added to BGP with `network` command
2. Route not in RIB (routing information base)
3. Next-hop unreachable

**Debugging Steps**:

```bash
# Check if route is in routing table
docker exec clab-bgp-ebgp-basics-r1 vtysh -c "show ip route 192.168.1.0/24"

# Check BGP configuration
docker exec clab-bgp-ebgp-basics-r1 vtysh -c "show run" | grep -A 10 "router bgp"

# Check what we're advertising to neighbor
docker exec clab-bgp-ebgp-basics-r1 vtysh -c "show ip bgp neighbors 10.1.1.2 advertised-routes"
```

**Solution**:
Ensure network is advertised in BGP:

```bash
docker exec clab-bgp-ebgp-basics-r1 vtysh
```

```
configure terminal
router bgp 100
 address-family ipv4 unicast
  network 192.168.1.0/24
 exit-address-family
end
```

---

## AS-Path Issues

### Issue: Route rejected due to AS-path loop

**Symptom**:
BGP neighbor sends route, but it's not installed in routing table.

**Cause**:
BGP's AS-path loop prevention mechanism rejects any route where the local AS number appears in the AS-path.

**Example**:
Router r1 (AS 100) will **reject** routes with AS-path containing `100` (like `200 300 100`).

**This is normal behavior** and prevents routing loops!

**Debugging**:

```bash
# Check AS-path for routes
docker exec clab-bgp-ebgp-basics-r1 vtysh -c "show ip bgp" | grep "Path"

# View detailed AS-path for specific prefix
docker exec clab-bgp-ebgp-basics-r1 vtysh -c "show ip bgp 192.168.4.0/24"
```

**Expected**: r1 (AS 100) should NOT accept route to 192.168.4.0/24 if AS-path is `200 300 100` (contains own AS).

---

## Container Issues

### Issue: Container not starting

**Symptom**:
```bash
docker ps | grep bgp-ebgp-basics
# Shows container is not running
```

**Debugging**:

```bash
# Check container logs
docker logs clab-bgp-ebgp-basics-r1

# Check if container exists but is stopped
docker ps -a | grep bgp-ebgp-basics-r1

# Try to start manually
docker start clab-bgp-ebgp-basics-r1
```

**Solution**:
```bash
# Destroy and redeploy lab
sudo containerlab destroy -t topology.clab.yml --cleanup
sudo containerlab deploy -t topology.clab.yml
```

---

### Issue: Validation tests failing

**Symptom**:
```bash
./scripts/validate.sh
# Shows multiple test failures
```

**Debugging**:

```bash
# Check all containers are running
docker ps | grep bgp-ebgp-basics

# Manually check BGP status on all routers
for router in r1 r2 r3 r4; do
  echo "=== $router BGP Summary ==="
  docker exec clab-bgp-ebgp-basics-$router vtysh -c "show ip bgp summary"
done

# Check connectivity between routers
docker exec clab-bgp-ebgp-basics-r1 ping -c 2 10.1.1.2  # r1 to r2
docker exec clab-bgp-ebgp-basics-r2 ping -c 2 10.2.2.2  # r2 to r3
```

**Common Fixes**:
1. Wait 30-60 seconds after deployment for BGP to converge
2. Restart BGP sessions: `clear ip bgp *`
3. Check FRR daemon is running: `docker exec clab-bgp-ebgp-basics-r1 ps aux | grep bgpd`

---

## Performance Issues

### Issue: Lab is slow to deploy

**Cause**: Docker pulling images for the first time

**Solution**:
Pre-pull images before deploying:

```bash
docker pull frrouting/frr:latest
```

---

### Issue: High memory usage

**Expected Memory**: ~200-300MB total for all 4 routers

If you're seeing higher usage:
1. Check for memory leaks: `docker stats`
2. Ensure no other containers are running
3. Restart Docker daemon

---

## Getting Help

If you're still stuck after trying these solutions:

1. **Check container logs**: `docker logs clab-bgp-ebgp-basics-r1`
2. **Verify lab deployment**: `containerlab inspect -t topology.clab.yml`
3. **Review FRR logs**: `docker exec clab-bgp-ebgp-basics-r1 cat /var/log/frr/bgpd.log`
4. **Open an issue**: https://github.com/ciscoittech/containerlab-free-labs/issues

---

## Quick Reference

**Container Management**:
```bash
# List all lab containers
docker ps | grep bgp-ebgp-basics

# Restart a container
docker restart clab-bgp-ebgp-basics-r1

# View container logs
docker logs clab-bgp-ebgp-basics-r1

# Access container shell
docker exec -it clab-bgp-ebgp-basics-r1 bash
```

**BGP Commands**:
```bash
# Check BGP summary
docker exec clab-bgp-ebgp-basics-r1 vtysh -c "show ip bgp summary"

# Reset BGP session
docker exec clab-bgp-ebgp-basics-r1 vtysh -c "clear ip bgp *"

# View configuration
docker exec clab-bgp-ebgp-basics-r1 vtysh -c "show run"

# Check specific route
docker exec clab-bgp-ebgp-basics-r1 vtysh -c "show ip bgp 192.168.3.0/24"
```
