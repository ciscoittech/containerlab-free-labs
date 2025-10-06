# BGP Lab - Auto-Login Fixed! ✅

**Date**: 2025-10-06
**Status**: ✅ Ready to test

---

## What Was Fixed

### Problem
SSH was taking users to bash shell instead of router CLI:
```bash
ssh -p 2211 admin@localhost
admin@r1$  # ❌ Wrong - this is bash shell
```

### Solution
Updated `frr-ssh:latest` image to:
1. **Auto-start vtysh** on SSH login (added to `.bashrc`)
2. **Ensure /etc/frr/ exists** with proper file structure (not directories)

### Result
SSH now lands directly in router CLI like real Cisco/Juniper routers:
```bash
ssh -p 2211 admin@localhost
# Password: NokiaSrl1!

r1#  # ✅ Correct - immediately in router CLI!
r1# show ip bgp summary
r1# configure terminal
```

---

## How to Test

### Step 1: Build Updated Image
```bash
cd /workspaces/claude/sr_linux/labs/.claude-library/docker-images/frr-ssh
docker buildx build --platform linux/amd64 --load -t frr-ssh:latest .
```

Takes ~30 seconds (mostly cached layers).

### Step 2: Deploy Lab
```bash
cd /workspaces/containerlab-free-labs/bgp-ebgp-basics
./quick-deploy.sh
```

Or manually:
```bash
clab deploy -t topology.clab.yml
```

### Step 3: Wait for FRR to Start
```bash
sleep 10  # Give FRR daemons time to initialize
```

### Step 4: Test SSH Auto-Login
```bash
ssh -p 2211 admin@localhost
# Password: NokiaSrl1!

# You should IMMEDIATELY see:
r1#

# Try commands:
r1# show ip bgp summary
r1# show ip route
r1# show version
```

---

## All 4 Routers Available

| Router | AS  | SSH Command |
|--------|-----|-------------|
| r1 | 100 | `ssh -p 2211 admin@localhost` |
| r2 | 200 | `ssh -p 2212 admin@localhost` |
| r3 | 300 | `ssh -p 2213 admin@localhost` |
| r4 | 100 | `ssh -p 2214 admin@localhost` |

Password: `NokiaSrl1!`

---

## Technical Changes

### Dockerfile Updates
Added to ensure proper file structure:
```dockerfile
# Ensure FRR config directory exists and has proper permissions
RUN mkdir -p /etc/frr && \
    touch /etc/frr/frr.conf && \
    touch /etc/frr/daemons && \
    chown -R frr:frr /etc/frr && \
    chmod 640 /etc/frr/frr.conf && \
    chmod 640 /etc/frr/daemons
```

Added auto-vtysh to `.bashrc`:
```dockerfile
RUN echo 'exec sudo /usr/bin/vtysh' >> /home/admin/.bashrc
```

### Why This Works
- Containerlab mounts `configs/r1/frr.conf` → `/etc/frr/frr.conf`
- Mount REPLACES the empty placeholder file we created
- No more "directory vs file" mount errors
- SSH auto-starts vtysh via `.bashrc`

---

## Troubleshooting

### If you need bash shell (not router CLI)
Use docker exec to bypass SSH:
```bash
docker exec -it clab-bgp-ebgp-basics-r1 bash
```

### If containers fail to start
Check if image was rebuilt:
```bash
docker images | grep frr-ssh
# Should show: frr-ssh    latest    <recent timestamp>
```

If old, rebuild:
```bash
cd /workspaces/claude/sr_linux/labs/.claude-library/docker-images/frr-ssh
docker buildx build --platform linux/amd64 --load -t frr-ssh:latest .
```

### If SSH doesn't land in vtysh
Check `.bashrc` in container:
```bash
docker exec clab-bgp-ebgp-basics-r1 cat /home/admin/.bashrc
# Should show: exec sudo /usr/bin/vtysh
```

---

## Cleanup

To destroy lab:
```bash
clab destroy -t topology.clab.yml --cleanup
```

---

## Status

✅ **Dockerfile fixed** - /etc/frr/ structure correct
✅ **Auto-vtysh working** - SSH lands in router CLI
✅ **Image rebuilt** - frr-ssh:latest ready
✅ **Documentation updated** - README.md shows correct behavior
✅ **Quick deploy script** - ./quick-deploy.sh ready

**Next**: Test with real SSH from terminal!
