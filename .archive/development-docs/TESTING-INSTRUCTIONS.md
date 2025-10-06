# Testing Instructions for Containerlab Free Labs

**Date**: October 2, 2025
**Purpose**: Validate all 3 labs in VS Code devcontainer environment

---

## Prerequisites

- VS Code installed with Remote-Containers extension
- Docker Desktop running on Mac
- At least 8GB RAM available
- Internet connection (for pulling container images)

---

## Testing Workflow

### Step 1: Test OSPF Basics Lab

```bash
# 1. Open lab in VS Code
cd /Users/bhunt/development/claude/containerlab-free-labs/ospf-basics
code .

# 2. When VS Code opens, click "Reopen in Container"
#    - First time will take 2-3 minutes to build devcontainer
#    - Pulls ghcr.io/srl-labs/containerlab/devcontainer-dind-slim:0.68.0
#    - Runs postCreateCommand: pulls frrouting/frr:latest

# 3. Once inside devcontainer, run deployment
./scripts/deploy.sh

# Expected output:
# - Deploys 3 FRR containers: r1, r2, r3
# - Completes in <30 seconds
# - Shows access commands

# 4. Wait 30 seconds for OSPF convergence
sleep 30

# 5. Run validation tests
./scripts/validate.sh

# Expected results:
# Test 1: ✓ PASSED - r1 has 2 OSPF neighbors in Full state
# Test 2: ✓ PASSED - r2 has 2 OSPF neighbors in Full state
# Test 3: ✓ PASSED - r3 has 2 OSPF neighbors in Full state
# Test 4: ✓ PASSED - r1 has route to 192.168.100.0/24
# Test 5: ✓ PASSED - r2 has route to 192.168.100.0/24
# Test 6: ✓ PASSED - r1 can ping 192.168.100.1
#
# Tests Passed: 6
# Tests Failed: 0
# ✓ All tests passed! Lab is working correctly.

# 6. Test manual exercises from README
docker exec -it clab-ospf-basics-r1 vtysh

# Inside vtysh:
show ip ospf neighbor
# Expected: 2 neighbors in Full state

show ip route ospf
# Expected: See learned OSPF routes

show ip ospf database
# Expected: See Router LSAs from all 3 routers

exit

# 7. Test ping connectivity
docker exec -it clab-ospf-basics-r1 ping -c 3 192.168.100.1
# Expected: 0% packet loss

# 8. Cleanup
./scripts/cleanup.sh

# Expected output:
# - Destroys all 3 containers
# - Clean shutdown
```

### Step 2: Test BGP eBGP Basics Lab

```bash
# 1. Open lab in VS Code
cd /Users/bhunt/development/claude/containerlab-free-labs/bgp-ebgp-basics
code .

# 2. Click "Reopen in Container"

# 3. Deploy lab
./scripts/deploy.sh

# Expected: 4 FRR containers deployed (r1, r2, r3, r4)

# 4. Wait for BGP convergence
sleep 30

# 5. Run validation tests
./scripts/validate.sh

# Expected results:
# Test 1: ✓ PASSED - r1 has 1 BGP neighbor in Established state
# Test 2: ✓ PASSED - r2 has 2 BGP neighbors in Established state
# Test 3: ✓ PASSED - r3 has 1 BGP neighbor in Established state
# Test 4: ✓ PASSED - r4 has 1 BGP neighbor in Established state
# Test 5: ✓ PASSED - r1 learned route to 192.168.3.0/24
# Test 6: ✓ PASSED - r1 can ping 192.168.3.1
#
# Tests Passed: 6
# Tests Failed: 0

# 6. Test manual exercises
docker exec -it clab-bgp-ebgp-basics-r1 vtysh

# Inside vtysh:
show ip bgp summary
# Expected: 1 neighbor in Established state

show ip bgp
# Expected: See routes with AS-path

show ip bgp 192.168.3.0/24
# Expected: See route with AS-path: 200 300

exit

# 7. Cleanup
./scripts/cleanup.sh
```

### Step 3: Test Linux Network Namespaces Lab

```bash
# 1. Open lab in VS Code
cd /Users/bhunt/development/claude/containerlab-free-labs/linux-network-namespaces
code .

# 2. Click "Reopen in Container"

# 3. Deploy lab
./scripts/deploy.sh

# Expected: 4 Alpine containers deployed (router, client1, client2, server)

# 4. Wait for containers to be ready
sleep 10

# 5. Run validation tests
./scripts/validate.sh

# Expected results:
# Test 1: ✓ PASSED - router has IP forwarding enabled
# Test 2: ✓ PASSED - client1 can reach router (10.0.1.1)
# Test 3: ✓ PASSED - client2 can reach router (10.0.2.1)
# Test 4: ✓ PASSED - server can reach router (10.0.3.1)
# Test 5: ✓ PASSED - client1 can reach server (10.0.3.10) through router
#
# Tests Passed: 5
# Tests Failed: 0

# 6. Test manual exercises
docker exec -it clab-netns-basics-router sh

# Inside container:
ip addr show
# Expected: See eth1 (10.0.1.1/24), eth2 (10.0.2.1/24), eth3 (10.0.3.1/24)

ip route show
# Expected: See connected routes

cat /proc/sys/net/ipv4/ip_forward
# Expected: 1 (forwarding enabled)

exit

# 7. Test cross-subnet connectivity
docker exec -it clab-netns-basics-client1 ping -c 3 10.0.3.10
# Expected: 0% packet loss (client1 → server through router)

# 8. Cleanup
./scripts/cleanup.sh
```

---

## Common Issues and Fixes

### Issue 1: Devcontainer fails to build

**Symptom**: VS Code shows error when reopening in container

**Fix**:
```bash
# Check Docker Desktop is running
docker ps

# Pull devcontainer image manually
docker pull ghcr.io/srl-labs/containerlab/devcontainer-dind-slim:0.68.0

# Restart VS Code and try again
```

### Issue 2: Containerlab deploy fails with permission denied

**Symptom**: `sudo: a terminal is required to read the password`

**Fix**: Ensure you're inside the devcontainer (should show in VS Code bottom-left corner). The devcontainer runs as `vscode` user with sudo access configured.

### Issue 3: FRR containers fail to start

**Symptom**: `docker ps` shows containers exiting immediately

**Fix**:
```bash
# Check container logs
docker logs clab-ospf-basics-r1

# Common issue: daemons file permissions
# Verify configs/r1/daemons exists and is readable

# Pull fresh FRR image
docker pull frrouting/frr:latest

# Redeploy
./scripts/cleanup.sh
./scripts/deploy.sh
```

### Issue 4: Validation tests fail with "No route found"

**Symptom**: Tests fail but containers are running

**Fix**:
```bash
# OSPF/BGP needs time to converge
# Wait 30-60 seconds after deployment

sleep 60
./scripts/validate.sh

# If still failing, check protocol status manually
docker exec -it clab-ospf-basics-r1 vtysh -c "show ip ospf neighbor"
```

### Issue 5: Cannot access router CLI

**Symptom**: `docker exec` commands fail

**Fix**:
```bash
# Check containers are running
docker ps | grep clab

# If containers not found, redeploy
./scripts/deploy.sh

# If containers exist but exec fails, try:
docker exec -it clab-ospf-basics-r1 sh
# Then manually run: vtysh
```

---

## Expected Performance Benchmarks

### OSPF Basics Lab
- **Deployment time**: <30 seconds
- **OSPF convergence**: 15-30 seconds
- **Memory usage**: ~150MB total (3 containers × 50MB)
- **Validation tests**: 6/6 pass in <5 seconds

### BGP eBGP Basics Lab
- **Deployment time**: <30 seconds
- **BGP convergence**: 30-45 seconds
- **Memory usage**: ~200MB total (4 containers × 50MB)
- **Validation tests**: 6/6 pass in <5 seconds

### Linux Network Namespaces Lab
- **Deployment time**: <20 seconds
- **Container ready**: 5-10 seconds
- **Memory usage**: ~80MB total (4 containers × 20MB Alpine)
- **Validation tests**: 5/5 pass in <3 seconds

---

## Testing Checklist

Use this checklist to track testing progress:

### OSPF Basics Lab
- [ ] Devcontainer builds successfully
- [ ] Lab deploys in <30 seconds
- [ ] All 6 validation tests pass
- [ ] Manual OSPF neighbor checks work
- [ ] Ping tests successful
- [ ] README exercises verified
- [ ] Cleanup works without errors

### BGP eBGP Basics Lab
- [ ] Devcontainer builds successfully
- [ ] Lab deploys in <30 seconds
- [ ] All 6 validation tests pass
- [ ] BGP neighbors show Established
- [ ] AS-path visible in routes
- [ ] Cross-AS ping works
- [ ] Cleanup successful

### Linux Network Namespaces Lab
- [ ] Devcontainer builds successfully
- [ ] Lab deploys in <20 seconds
- [ ] All 5 validation tests pass
- [ ] IP forwarding enabled
- [ ] Cross-subnet routing works
- [ ] README exercises verified
- [ ] Cleanup successful

---

## Reporting Issues

If you encounter issues during testing:

1. **Document the error**: Copy exact error messages
2. **Check environment**:
   - Docker Desktop version
   - VS Code version
   - Available RAM/CPU
3. **Collect logs**:
   ```bash
   docker logs clab-<lab-name>-<node>
   containerlab inspect -t topology.clab.yml
   ```
4. **Create GitHub issue**: Include all above information

---

## Success Criteria

All labs pass testing when:
- ✅ All validation tests show 100% pass rate
- ✅ Deployment completes within performance benchmarks
- ✅ Manual README exercises work as documented
- ✅ Cleanup leaves no orphaned containers
- ✅ Labs work consistently across multiple deployments

---

*Last Updated: October 2, 2025*
