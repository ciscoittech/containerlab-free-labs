# OSPF Basics Lab - Troubleshooting Guide

This guide covers common issues you may encounter in the OSPF Basics lab.

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
docker exec -it clab-ospf-basics-r1 vtysh

# Run OSPF commands directly
docker exec clab-ospf-basics-r1 vtysh -c "show ip ospf neighbor"
docker exec clab-ospf-basics-r1 vtysh -c "show ip route ospf"
docker exec clab-ospf-basics-r1 vtysh -c "show ip ospf database"

# Access bash shell (for advanced debugging)
docker exec -it clab-ospf-basics-r1 bash
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

## OSPF Neighbor Issues

### Issue: OSPF neighbors stuck in Init or 2-Way state

**Symptom**:
```
show ip ospf neighbor
Neighbor ID     Pri State           Dead Time Address         Interface
2.2.2.2           1 Init/DROther    00:00:35  10.0.1.2        eth1
```

**Possible Causes**:
1. **Init state**: Router is not receiving Hello packets back from neighbor
2. **2-Way state on point-to-point**: Normal on broadcast networks if not DR/BDR, but not expected on point-to-point

**Debugging Steps**:

```bash
# Check OSPF interface configuration
docker exec clab-ospf-basics-r1 vtysh -c "show ip ospf interface"

# Check if Hello packets are being sent
docker exec clab-ospf-basics-r1 vtysh -c "show ip ospf neighbor detail"

# Verify interface is UP
docker exec clab-ospf-basics-r1 ip link show eth1

# Check IP addressing
docker exec clab-ospf-basics-r1 ip addr show eth1
```

**Solution**:
1. Verify interfaces are UP: `ip link show`
2. Check network type: Point-to-point interfaces should go to Full, broadcast can stay in 2-Way
3. Verify Hello/Dead intervals match on both sides
4. Check for firewall blocking OSPF multicast (224.0.0.5)

---

### Issue: OSPF neighbors not forming at all

**Symptom**:
```
show ip ospf neighbor
(empty output)
```

**Possible Causes**:
1. OSPF not configured on interface
2. Interface is DOWN
3. IP subnet mismatch between routers
4. Area mismatch

**Debugging Steps**:

```bash
# Check OSPF configuration
docker exec clab-ospf-basics-r1 vtysh -c "show run" | grep -A 10 "router ospf"

# Check which interfaces have OSPF enabled
docker exec clab-ospf-basics-r1 vtysh -c "show ip ospf interface"

# Check interface status
docker exec clab-ospf-basics-r1 ip addr show

# Test connectivity to neighbor
docker exec clab-ospf-basics-r1 ping -c 3 10.0.1.2
```

**Solution**:
Ensure OSPF is configured on the interface:

```bash
docker exec clab-ospf-basics-r1 vtysh
```

```
configure terminal
router ospf
 network 10.0.1.0/24 area 0
end
```

---

### Issue: OSPF neighbor stuck in ExStart/Exchange state

**Symptom**:
```
Neighbor ID     Pri State           Dead Time Address         Interface
2.2.2.2           1 ExStart/DR      00:00:35  10.0.1.2        eth1
```

**Cause**:
Router cannot exchange OSPF database descriptors. Usually caused by MTU mismatch.

**Debugging Steps**:

```bash
# Check MTU on interface
docker exec clab-ospf-basics-r1 ip link show eth1 | grep mtu

# Check OSPF neighbor details
docker exec clab-ospf-basics-r1 vtysh -c "show ip ospf neighbor detail"
```

**Solution**:
Ensure MTU matches on both sides (default is 1500):

```bash
# Set MTU to 1500 if needed
docker exec clab-ospf-basics-r1 ip link set eth1 mtu 1500
```

Or disable MTU mismatch detection (not recommended):

```bash
docker exec clab-ospf-basics-r1 vtysh
```

```
configure terminal
interface eth1
 ip ospf mtu-ignore
end
```

---

## Route Advertisement Issues

### Issue: Routes not appearing in routing table

**Symptom**:
OSPF neighbor is in Full state, but routes are missing from routing table.

**Possible Causes**:
1. Route not in OSPF database
2. Better route exists via another protocol
3. OSPF cost calculation issue

**Debugging Steps**:

```bash
# Check OSPF database
docker exec clab-ospf-basics-r1 vtysh -c "show ip ospf database"

# Check routing table
docker exec clab-ospf-basics-r1 vtysh -c "show ip route"

# Check if route is in OSPF database but not installed
docker exec clab-ospf-basics-r1 vtysh -c "show ip ospf route"
```

**Solution**:
```bash
# Verify network is advertised in OSPF
docker exec clab-ospf-basics-r1 vtysh -c "show run" | grep -A 5 "router ospf"

# If missing, add network
docker exec clab-ospf-basics-r1 vtysh
```

```
configure terminal
router ospf
 network 192.168.100.0/24 area 0
end
```

---

## DR/BDR Election Issues

### Issue: Wrong router elected as DR

**Symptom**:
Router with lower priority or router ID is DR instead of expected router.

**Cause**:
DR/BDR election is **non-preemptive**. The first router to come up becomes DR.

**This is normal OSPF behavior!**

**To force re-election**:

```bash
# Clear OSPF process on all routers (will cause brief outage)
docker exec clab-ospf-basics-r1 vtysh -c "clear ip ospf process"
docker exec clab-ospf-basics-r2 vtysh -c "clear ip ospf process"
docker exec clab-ospf-basics-r3 vtysh -c "clear ip ospf process"
```

**Or set priority** to influence election:

```bash
docker exec clab-ospf-basics-r1 vtysh
```

```
configure terminal
interface eth1
 ip ospf priority 100
end
```

(Higher priority wins, 0 = never become DR)

---

## Performance Issues

### Issue: OSPF convergence is slow

**Symptom**:
Routes take a long time to appear after topology change.

**Expected Convergence**:
- OSPF should converge in **<5 seconds** in this small topology

**Debugging**:

```bash
# Check Hello/Dead intervals
docker exec clab-ospf-basics-r1 vtysh -c "show ip ospf interface eth1"

# Default: Hello = 10 seconds, Dead = 40 seconds
```

**Speed up convergence** (for lab only, not production):

```bash
docker exec clab-ospf-basics-r1 vtysh
```

```
configure terminal
interface eth1
 ip ospf hello-interval 1
 ip ospf dead-interval 3
end
```

---

## Container Issues

### Issue: Container not starting

**Symptom**:
```bash
docker ps | grep ospf-basics
# Shows container is not running
```

**Debugging**:

```bash
# Check container logs
docker logs clab-ospf-basics-r1

# Check if container exists but is stopped
docker ps -a | grep ospf-basics-r1

# Try to start manually
docker start clab-ospf-basics-r1
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
# Shows test failures
```

**Debugging**:

```bash
# Check all containers are running
docker ps | grep ospf-basics

# Manually verify OSPF on all routers
for router in r1 r2 r3; do
  echo "=== $router OSPF Neighbors ==="
  docker exec clab-ospf-basics-$router vtysh -c "show ip ospf neighbor"
done

# Check connectivity
docker exec clab-ospf-basics-r1 ping -c 2 10.0.1.2  # r1 to r2
docker exec clab-ospf-basics-r1 ping -c 2 10.0.2.3  # r1 to r3
```

**Common Fixes**:
1. Wait 30-60 seconds after deployment for OSPF to converge
2. Verify all interfaces are UP
3. Check OSPF is configured on all interfaces
4. Ensure area is consistent (Area 0)

---

## Configuration Issues

### Issue: Configuration changes not taking effect

**Symptom**:
Changed OSPF configuration but nothing happens.

**Cause**:
Forgot to commit changes or reload OSPF.

**Solution**:

```bash
# In vtysh configuration mode, always end with:
configure terminal
router ospf
 network 10.0.1.0/24 area 0
end

# Write configuration to save (optional in containers)
write memory

# Clear OSPF process to reload (if needed)
clear ip ospf process
```

---

## Getting Help

If you're still stuck after trying these solutions:

1. **Check container logs**: `docker logs clab-ospf-basics-r1`
2. **Verify lab deployment**: `containerlab inspect -t topology.clab.yml`
3. **Review FRR logs**: `docker exec clab-ospf-basics-r1 cat /var/log/frr/ospfd.log`
4. **Open an issue**: https://github.com/ciscoittech/containerlab-free-labs/issues

---

## Quick Reference

**Container Management**:
```bash
# List all lab containers
docker ps | grep ospf-basics

# Restart a container
docker restart clab-ospf-basics-r1

# View container logs
docker logs clab-ospf-basics-r1

# Access container shell
docker exec -it clab-ospf-basics-r1 bash
```

**OSPF Commands**:
```bash
# Check OSPF neighbors
docker exec clab-ospf-basics-r1 vtysh -c "show ip ospf neighbor"

# View OSPF database
docker exec clab-ospf-basics-r1 vtysh -c "show ip ospf database"

# Check OSPF routes
docker exec clab-ospf-basics-r1 vtysh -c "show ip route ospf"

# View interface details
docker exec clab-ospf-basics-r1 vtysh -c "show ip ospf interface"

# Clear OSPF process
docker exec clab-ospf-basics-r1 vtysh -c "clear ip ospf process"
```
