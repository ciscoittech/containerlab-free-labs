# Manual Testing Log

**Created**: October 2, 2025
**Purpose**: Track manual testing results for all 3 labs before marketing launch

---

## Testing Status Overview

| Lab | Devcontainer | Deployment | Validation | Manual Tests | Status |
|-----|-------------|------------|------------|--------------|--------|
| OSPF Basics | ⏳ Pending | ⏳ Pending | ⏳ Pending | ⏳ Pending | ⏳ Not Tested |
| BGP eBGP Basics | ⏳ Pending | ⏳ Pending | ⏳ Pending | ⏳ Pending | ⏳ Not Tested |
| Linux Namespaces | ⏳ Pending | ⏳ Pending | ⏳ Pending | ⏳ Pending | ⏳ Not Tested |

**Legend**: ✅ Pass | ❌ Fail | ⏳ Pending | ⚠️ Issue Found

---

## OSPF Basics Lab Testing

### Test Environment
- **Date**: _____________
- **Tester**: _____________
- **Docker Desktop Version**: _____________
- **VS Code Version**: _____________
- **Mac OS Version**: _____________
- **Available RAM**: _____________

### Devcontainer Build
- [ ] Opens in VS Code successfully
- [ ] Devcontainer builds without errors
- [ ] postCreateCommand completes
- [ ] FRR image pulled successfully

**Build Time**: _______ minutes
**Issues**: _____________________________________________

### Deployment
- [ ] `./scripts/deploy.sh` runs without errors
- [ ] 3 containers created (r1, r2, r3)
- [ ] Deployment completes in <30 seconds

**Deployment Time**: _______ seconds
**Container Status**:
```
# Paste output of: docker ps | grep clab-ospf
```

**Issues**: _____________________________________________

### Validation Tests
- [ ] Test 1: r1 has 2 OSPF neighbors - PASS/FAIL
- [ ] Test 2: r2 has 2 OSPF neighbors - PASS/FAIL
- [ ] Test 3: r3 has 2 OSPF neighbors - PASS/FAIL
- [ ] Test 4: r1 learned route to 192.168.100.0/24 - PASS/FAIL
- [ ] Test 5: r2 learned route to 192.168.100.0/24 - PASS/FAIL
- [ ] Test 6: r1 can ping 192.168.100.1 - PASS/FAIL

**Test Output**:
```
# Paste output of: ./scripts/validate.sh
```

**Issues**: _____________________________________________

### Manual Exercises
- [ ] `show ip ospf neighbor` works on all routers
- [ ] All neighbors in Full state
- [ ] `show ip route ospf` shows learned routes
- [ ] `show ip ospf database` shows LSAs from all routers
- [ ] Ping from r1 to 192.168.100.1 works

**Sample Command Outputs**:
```
# Paste key command outputs here
```

**Issues**: _____________________________________________

### Cleanup
- [ ] `./scripts/cleanup.sh` runs without errors
- [ ] All containers removed
- [ ] No orphaned containers remaining

**Issues**: _____________________________________________

### Overall Result
- **Status**: ✅ PASS / ❌ FAIL / ⚠️ PARTIAL
- **Notes**: _____________________________________________

---

## BGP eBGP Basics Lab Testing

### Test Environment
- **Date**: _____________
- **Tester**: _____________
- **Docker Desktop Version**: _____________
- **VS Code Version**: _____________

### Devcontainer Build
- [ ] Opens in VS Code successfully
- [ ] Devcontainer builds without errors
- [ ] postCreateCommand completes

**Build Time**: _______ minutes
**Issues**: _____________________________________________

### Deployment
- [ ] `./scripts/deploy.sh` runs without errors
- [ ] 4 containers created (r1, r2, r3, r4)
- [ ] Deployment completes in <30 seconds

**Deployment Time**: _______ seconds
**Container Status**:
```
# Paste output of: docker ps | grep clab-bgp
```

**Issues**: _____________________________________________

### Validation Tests
- [ ] Test 1: r1 has 1 BGP neighbor Established - PASS/FAIL
- [ ] Test 2: r2 has 2 BGP neighbors Established - PASS/FAIL
- [ ] Test 3: r3 has 1 BGP neighbor Established - PASS/FAIL
- [ ] Test 4: r4 has 1 BGP neighbor Established - PASS/FAIL
- [ ] Test 5: r1 learned route to 192.168.3.0/24 - PASS/FAIL
- [ ] Test 6: r1 can ping 192.168.3.1 - PASS/FAIL

**Test Output**:
```
# Paste output of: ./scripts/validate.sh
```

**Issues**: _____________________________________________

### Manual Exercises
- [ ] `show ip bgp summary` shows all neighbors Established
- [ ] `show ip bgp` displays routes with AS-path
- [ ] AS-path shows correct AS numbers (100, 200, 300)
- [ ] Routes from AS 300 visible in AS 100 (via AS 200)
- [ ] Ping from r1 (AS 100) to r4 (AS 300) works

**Sample Command Outputs**:
```
# Paste key command outputs here
```

**Issues**: _____________________________________________

### Cleanup
- [ ] `./scripts/cleanup.sh` runs without errors
- [ ] All containers removed

**Issues**: _____________________________________________

### Overall Result
- **Status**: ✅ PASS / ❌ FAIL / ⚠️ PARTIAL
- **Notes**: _____________________________________________

---

## Linux Network Namespaces Lab Testing

### Test Environment
- **Date**: _____________
- **Tester**: _____________
- **Docker Desktop Version**: _____________
- **VS Code Version**: _____________

### Devcontainer Build
- [ ] Opens in VS Code successfully
- [ ] Devcontainer builds without errors
- [ ] Alpine image pulled successfully

**Build Time**: _______ minutes
**Issues**: _____________________________________________

### Deployment
- [ ] `./scripts/deploy.sh` runs without errors
- [ ] 4 containers created (router, client1, client2, server)
- [ ] Deployment completes in <20 seconds

**Deployment Time**: _______ seconds
**Container Status**:
```
# Paste output of: docker ps | grep clab-netns
```

**Issues**: _____________________________________________

### Validation Tests
- [ ] Test 1: router has IP forwarding enabled - PASS/FAIL
- [ ] Test 2: client1 can reach router - PASS/FAIL
- [ ] Test 3: client2 can reach router - PASS/FAIL
- [ ] Test 4: server can reach router - PASS/FAIL
- [ ] Test 5: client1 can reach server through router - PASS/FAIL

**Test Output**:
```
# Paste output of: ./scripts/validate.sh
```

**Issues**: _____________________________________________

### Manual Exercises
- [ ] `ip addr show` displays all interfaces correctly
- [ ] Router has 3 interfaces: eth1, eth2, eth3
- [ ] IP forwarding enabled (value = 1)
- [ ] Routing table shows connected routes
- [ ] Cross-subnet ping works (client1 → server)

**Sample Command Outputs**:
```
# Paste key command outputs here
```

**Issues**: _____________________________________________

### Cleanup
- [ ] `./scripts/cleanup.sh` runs without errors
- [ ] All containers removed

**Issues**: _____________________________________________

### Overall Result
- **Status**: ✅ PASS / ❌ FAIL / ⚠️ PARTIAL
- **Notes**: _____________________________________________

---

## Summary and Action Items

### Testing Summary

**Total Labs**: 3
**Labs Passed**: _______
**Labs Failed**: _______
**Labs With Issues**: _______

### Issues Found

1. **Issue**: _____________________________________________
   - **Lab**: _____________
   - **Severity**: Critical / High / Medium / Low
   - **Action**: _____________________________________________

2. **Issue**: _____________________________________________
   - **Lab**: _____________
   - **Severity**: Critical / High / Medium / Low
   - **Action**: _____________________________________________

### Required Fixes Before Launch

- [ ] Fix: _____________________________________________
- [ ] Fix: _____________________________________________
- [ ] Fix: _____________________________________________

### Documentation Updates Needed

- [ ] Update: _____________________________________________
- [ ] Update: _____________________________________________

### Ready for Launch?

- [ ] All 3 labs tested
- [ ] All validation tests pass (17/17 total)
- [ ] All manual exercises verified
- [ ] No critical issues found
- [ ] Documentation accurate

**Launch Approval**: YES / NO / PENDING

**Approver**: _____________________________________________
**Date**: _____________________________________________

---

## Performance Benchmarks (Actual vs Expected)

| Metric | OSPF Lab | BGP Lab | Netns Lab | Expected |
|--------|----------|---------|-----------|----------|
| Devcontainer build | ___ min | ___ min | ___ min | 2-3 min |
| Deployment time | ___ sec | ___ sec | ___ sec | <30 sec |
| Protocol convergence | ___ sec | ___ sec | ___ sec | 30-60 sec |
| Validation runtime | ___ sec | ___ sec | ___ sec | <5 sec |
| Memory usage | ___ MB | ___ MB | ___ MB | 150-200 MB |

---

## Recommendations for Improvement

1. _____________________________________________
2. _____________________________________________
3. _____________________________________________

---

*Testing log created: October 2, 2025*
*Status: Ready for manual testing in VS Code devcontainer*
