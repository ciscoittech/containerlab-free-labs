# BGP eBGP Basics Lab - SSH Enabled ✅

**Date Updated**: 2025-10-06 (Updated with auto-vtysh)
**Status**: ✅ SSH Access Fully Enabled with Auto-Login to Router CLI

---

## What Changed

This lab has been upgraded from standard FRR containers to custom FRR SSH-enabled containers.

### Before (Old)
- ❌ No SSH access
- ❌ Only `docker exec` to access routers
- ❌ Not realistic for network engineers
- ❌ Hard to copy/paste configs

### After (New) ✅
- ✅ Direct SSH access to all 4 routers
- ✅ Unique SSH ports per router (2211-2214)
- ✅ **Auto-login to router CLI** - SSH drops you directly into vtysh (like real routers!)
- ✅ Realistic network experience (no bash shell, straight to CLI)
- ✅ Easy config management
- ✅ Works from code-server/VS Code terminal

---

## SSH Access

| Router | AS  | SSH Port | Command |
|--------|-----|----------|---------|
| **r1** | 100 | 2211 | `ssh -p 2211 admin@localhost` |
| **r2** | 200 | 2212 | `ssh -p 2212 admin@localhost` |
| **r3** | 300 | 2213 | `ssh -p 2213 admin@localhost` |
| **r4** | 100 | 2214 | `ssh -p 2214 admin@localhost` |

**Credentials**:
- Username: `admin`
- Password: `NokiaSrl1!`

---

## Example Usage

### SSH to r1 (AS 100) - Auto-Login to Router CLI
```bash
ssh -p 2211 admin@localhost
# Password: NokiaSrl1!

# You land DIRECTLY in router CLI - no bash shell!
r1# show ip bgp summary
r1# show ip bgp
r1# show ip route
r1# configure terminal
r1(config)# router bgp 100
```

✨ **NEW**: SSH auto-starts vtysh - behaves exactly like real Cisco/Juniper routers!

### SSH to r2 (AS 200 - Transit)
```bash
ssh -p 2212 admin@localhost
# Password: NokiaSrl1!

# Direct router CLI access
r2# show ip bgp neighbors
r2# show ip bgp neighbors 10.1.1.1 advertised-routes
```

---

## Files Modified

1. **`topology.clab.yml`**
   - Changed image from `frrouting/frr:latest` to `frr-ssh:latest`
   - Added SSH port mappings (2211-2214)
   - Added labels for lab metadata

2. **`README.md`**
   - Added Prerequisites section (frr-ssh image requirement)
   - Updated "Accessing Lab Devices" section
   - Added SSH access table with ports and commands
   - Kept docker exec as alternative method

3. **`scripts/deploy.sh`**
   - Updated output to show SSH commands first
   - Added password reminder
   - Kept docker exec as alternative

---

## Prerequisites

**Must have frr-ssh image built**:
```bash
cd /Users/bhunt/development/claude/sr_linux/labs/.claude-library/docker-images/frr-ssh
docker buildx build --platform linux/amd64 --load -t frr-ssh:latest .
```

Takes ~2 minutes first time, then cached.

---

## Testing

### Quick Test
```bash
# Deploy lab
cd /Users/bhunt/development/claude/containerlab-free-labs/bgp-ebgp-basics
./scripts/deploy.sh

# Wait 5 seconds for SSH to start
sleep 5

# Test SSH to r1
ssh -p 2211 admin@localhost
# Password: NokiaSrl1!

# Check BGP
vtysh -c "show ip bgp summary"
```

### Expected Results
- All 4 routers accessible via SSH
- BGP sessions established between AS boundaries
- Can configure routers via SSH terminal
- vtysh commands work correctly

---

## Benefits

✅ **Realistic Experience** - SSH to routers like real hardware (direct CLI login!)
✅ **Browser-Friendly** - Works in code-server terminal
✅ **Easy Config Management** - Copy/paste configs easily
✅ **Multi-User** - Multiple students can SSH simultaneously
✅ **Tool Compatible** - Works with Ansible, Nornir, etc.
✅ **Authentic Workflow** - No bash shell, just router CLI like Cisco/Juniper

---

## Troubleshooting

**Need bash shell access?** Use docker exec to bypass SSH auto-login:
```bash
docker exec -it clab-bgp-ebgp-basics-r1 bash
```

**Need to exit?** Just type `exit` - it exits SSH completely (not just vtysh):
```bash
r1# exit
# You're back at your terminal
```

---

## Backwards Compatibility

**Docker exec still works**:
```bash
docker exec -it clab-bgp-ebgp-basics-r1 vtysh
```

Both methods are documented in README.md.

---

## Next Steps

If deploying for SaaS platform:
1. ✅ SSH access ready
2. ✅ Port mappings configured
3. ✅ Documentation updated
4. Consider: Add to code-server pre-warmed slots
5. Consider: Document firewall rules if needed

---

**Status**: ✅ Ready for Production Use
