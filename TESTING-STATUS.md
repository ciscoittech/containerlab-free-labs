# Free Labs Testing Status

**Created**: October 2, 2025
**Status**: Labs created, devcontainer testing required

---

## Lab Inventory

### 1. OSPF Basics
**Status**: ✅ Created, ⚠️ Devcontainer testing required
**Files**:
- ✅ topology.clab.yml
- ✅ configs/r1,r2,r3/frr.conf
- ✅ scripts/deploy.sh, validate.sh, cleanup.sh
- ✅ .devcontainer/devcontainer.json
- ✅ README.md (5.3KB, comprehensive)

**Validation Tests**: 6 tests
1. r1 has 2 OSPF neighbors in Full state
2. r2 has 2 OSPF neighbors in Full state
3. r3 has 2 OSPF neighbors in Full state
4. r1 learned route to 192.168.100.0/24
5. r2 learned route to 192.168.100.0/24
6. Connectivity test (r1 → 192.168.100.1)

**Testing Required**:
- [ ] Deploy in VS Code devcontainer
- [ ] Run `./scripts/validate.sh` - expect 6/6 tests pass
- [ ] Verify FRR container startup time (<30 seconds)
- [ ] Test all exercises in README.md

---

### 2. BGP eBGP Basics
**Status**: ✅ Created, ⚠️ Devcontainer testing required
**Files**:
- ✅ topology.clab.yml
- ✅ configs/r1,r2,r3,r4/frr.conf
- ✅ scripts/deploy.sh, validate.sh, cleanup.sh
- ✅ .devcontainer/devcontainer.json
- ✅ README.md (comprehensive with troubleshooting exercises)

**Validation Tests**: 6 tests
1. r1 has established BGP session with AS 200
2. r2 has 2 established BGP sessions
3. r1 learned at least 3 BGP routes
4. r4 learned route to 192.168.3.0/24 (AS 300)
5. r1 sees correct AS-path for AS 300 routes
6. Connectivity test (r1 → r3 loopback)

**Testing Required**:
- [ ] Deploy in VS Code devcontainer
- [ ] Run `./scripts/validate.sh` - expect 6/6 tests pass
- [ ] Verify BGP neighbor establishment time
- [ ] Test AS-path verification commands
- [ ] Test all exercises in README.md

---

### 3. Linux Network Namespaces
**Status**: ✅ Created, ⚠️ Devcontainer testing required
**Files**:
- ✅ topology.clab.yml
- ✅ scripts/deploy.sh, validate.sh, cleanup.sh
- ✅ .devcontainer/devcontainer.json
- ✅ README.md (educational focus, namespace concepts)

**Validation Tests**: 5 tests
1. host1 can ping router (10.0.1.1)
2. host2 can ping router (10.0.1.1)
3. host1 and host2 can ping each other
4. IP forwarding enabled on router
5. host1 can ping host3 via router

**Testing Required**:
- [ ] Deploy in VS Code devcontainer
- [ ] Run `./scripts/validate.sh` - expect 5/5 tests pass
- [ ] Test all namespace exploration exercises
- [ ] Verify educational value for beginners

---

## Testing Instructions

### Prerequisites
- VS Code installed
- Docker Desktop running (Mac)
- Git clone the containerlab-free-labs repo

### Testing Workflow

**For each lab**:

1. **Open lab in VS Code**:
   ```bash
   cd containerlab-free-labs/<lab-name>
   code .
   ```

2. **Reopen in devcontainer**:
   - Click "Reopen in Container" when prompted
   - Wait for container to build (first time: ~2-3 minutes)
   - Devcontainer will auto-run `postCreateCommand`

3. **Deploy the lab**:
   ```bash
   ./scripts/deploy.sh
   ```
   - Expected: Containerlab deploys topology in <30 seconds
   - Check for errors in output

4. **Run validation tests**:
   ```bash
   ./scripts/validate.sh
   ```
   - Expected: All tests pass (6/6, 6/6, or 5/5)
   - If failures, investigate with manual commands

5. **Test manual exercises**:
   - Follow README.md exercises
   - Verify commands work as documented
   - Check that examples match actual output

6. **Cleanup**:
   ```bash
   ./scripts/cleanup.sh
   ```
   - Expected: Clean shutdown, no orphaned containers

---

## Known Limitations

### Cannot Test on Mac Host Directly
- Containerlab requires Linux kernel
- **Solution**: Use VS Code devcontainer (Linux environment)
- Devcontainer uses: `ghcr.io/srl-labs/containerlab/devcontainer-dood-slim:0.66.0`

### Docker-in-Docker (DooD)
- Devcontainer uses Docker-outside-of-Docker
- Host Docker socket mounted at `/var/run/docker.sock`
- Containers created by containerlab visible on host

### Sudo in Devcontainer
- Containerlab may require sudo depending on setup
- Scripts include sudo commands
- Devcontainer user (`vscode`) should have sudo access

---

## Success Criteria

**Before publishing to GitHub**, each lab must:

- ✅ Deploy successfully in devcontainer (<30 seconds)
- ✅ Pass all validation tests (100% pass rate)
- ✅ All README exercises work as documented
- ✅ No errors or warnings during deployment
- ✅ Clean shutdown with no orphaned resources

---

## Next Steps

1. **Test OSPF Basics lab**
   - Open in VS Code
   - Deploy in devcontainer
   - Run all tests

2. **Test BGP eBGP Basics lab**
   - Same workflow as OSPF

3. **Test Linux Namespaces lab**
   - Same workflow

4. **Fix any issues found**
   - Update configs if needed
   - Fix validation scripts
   - Update documentation

5. **Create final GitHub repo README**
   - Add badges (if CI/CD added)
   - Link to each lab
   - Marketing content

6. **Publish to GitHub**
   - Push to public repo
   - Tag as v1.0
   - Announce on Reddit/LinkedIn

---

*Last Updated: October 2, 2025*
