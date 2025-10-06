# 🔐 SSH Credentials Final - Rebuild Required

**Date Updated**: 2025-10-06
**Status**: ✅ All labs updated to `admin/cisco` credentials

---

## Current Credentials (Final)

**Username**: `admin`
**Password**: `cisco`

---

## Credential History

**Original** (deprecated):
- Username: `admin`
- Password: `NokiaSrl1!` (too complex)

**Attempt 2** (deprecated):
- Username: `cisco`
- Password: `cisco` (conflicted with VS Code extension)

**Final** (current):
- Username: `admin`
- Password: `cisco`

---

## Why admin/cisco?

✅ **VS Code compatibility** - Extension hardcodes `admin` username for SSH
✅ **Simple password** - Just type `cisco` - easy to remember
✅ **No workarounds** - Right-click SSH in VS Code works perfectly
✅ **Best of both** - Matches extension default + simple credentials

---

## You Must Rebuild!

**In GitHub Codespaces:**

```bash
# 1. Pull latest changes
git pull

# 2. Destroy existing labs
cd bgp-ebgp-basics
clab destroy -t topology.clab.yml --cleanup

# 3. Remove old image with old credentials
docker rmi frr-ssh:latest

# 4. Rebuild with new admin/cisco credentials
cd /workspaces/containerlab-free-labs
./build-frr-ssh.sh

# 5. Redeploy lab
cd bgp-ebgp-basics
clab deploy -t topology.clab.yml
sleep 10

# 6. Test with NEW credentials
ssh -p 2211 admin@localhost
# Password: cisco
```

---

## New SSH Commands

**BGP eBGP Basics Lab:**
```bash
ssh -p 2211 admin@localhost  # r1 (AS 100)
ssh -p 2212 admin@localhost  # r2 (AS 200)
ssh -p 2213 admin@localhost  # r3 (AS 300)
ssh -p 2214 admin@localhost  # r4 (AS 100)
```

**OSPF Basics Lab:**
```bash
ssh -p 2221 admin@localhost  # r1
ssh -p 2222 admin@localhost  # r2
ssh -p 2223 admin@localhost  # r3
```

**Enterprise VPN Migration Lab:**
```bash
ssh -p 2231 admin@localhost  # router-a1 (Chicago)
ssh -p 2232 admin@localhost  # router-a2 (Chicago)
ssh -p 2233 admin@localhost  # router-b1 (Austin)
ssh -p 2234 admin@localhost  # router-b2 (Austin)
ssh -p 2235 admin@localhost  # internet-core (ISP)
```

**All labs**: Username is `admin`, password is `cisco`

---

## Expected Behavior

**After rebuild:**
```bash
ssh -p 2211 admin@localhost
Password: cisco

r1#  # Lands directly in router CLI
r1# show ip bgp summary
```

**Also works - VS Code Extension:**
- Right-click any container
- Click "SSH"
- Press Enter (shows `admin@` - perfect!)
- Password: `cisco`
- Lands at `r1#` immediately

---

## Files Updated

**Core Image Files:**
- `/build-frr-ssh.sh` - Codespaces build script
- `/.claude-library/docker-images/frr-ssh/Dockerfile` - Main Dockerfile

**Lab Documentation:**
- `bgp-ebgp-basics/README.md`
- `bgp-ebgp-basics/SSH-ENABLED-NOTES.md`
- `ospf-basics/README.md`
- `enterprise-vpn-migration/README.md`
- `enterprise-vpn-migration/SSH-ENABLED-NOTES.md`

**Top-Level Docs:**
- `README-CODESPACES.md`
- `REBUILD-NOW.md`

---

## Troubleshooting

### "Permission denied" error
**Symptom**: SSH fails with permission denied

**Cause**: Using old password or old image still cached

**Solution**: Ensure you're using `admin/cisco` and rebuild if needed:
```bash
docker rmi frr-ssh:latest
./build-frr-ssh.sh
```

### Still prompts for NokiaSrl1! password
**Symptom**: New containers still use old `NokiaSrl1!` password

**Cause**: Old `frr-ssh:latest` image still cached

**Solution**: Rebuild image:
```bash
docker rmi frr-ssh:latest
./build-frr-ssh.sh
```

### Lab won't deploy
**Symptom**: `clab deploy` fails with "no such image"

**Cause**: Forgot to rebuild frr-ssh image

**Solution**: Run `./build-frr-ssh.sh` first

---

## Quick Migration Checklist

- [ ] `git pull` to get latest changes
- [ ] `clab destroy` existing labs
- [ ] `docker rmi frr-ssh:latest` to remove old image
- [ ] `./build-frr-ssh.sh` to rebuild with admin/cisco credentials
- [ ] `clab deploy` labs with new image
- [ ] Test SSH with `admin/cisco` credentials

---

**Do this now in Codespaces!** Your users will love the seamless VS Code SSH experience. 🚀
