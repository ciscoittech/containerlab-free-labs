# 🔐 SSH Credentials Changed - Rebuild Required

**Date**: 2025-10-06
**Status**: ✅ All labs updated to `cisco/cisco` credentials

---

## What Changed

SSH credentials have been updated to use familiar Cisco-style login:

**Old Credentials** (deprecated):
- Username: `admin`
- Password: `NokiaSrl1!`

**New Credentials** (current):
- Username: `cisco`
- Password: `cisco`

---

## Why This Change?

✅ **More intuitive** - Network engineers expect `cisco/cisco` for lab environments
✅ **Easier to remember** - Simple, industry-standard credentials
✅ **Better UX** - Matches real-world Cisco lab equipment conventions

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

# 4. Rebuild with new cisco/cisco credentials
cd /workspaces/containerlab-free-labs
./build-frr-ssh.sh

# 5. Redeploy lab
cd bgp-ebgp-basics
clab deploy -t topology.clab.yml
sleep 10

# 6. Test with NEW credentials
ssh -p 2211 cisco@localhost
# Password: cisco
```

---

## New SSH Commands

**BGP eBGP Basics Lab:**
```bash
ssh -p 2211 cisco@localhost  # r1 (AS 100)
ssh -p 2212 cisco@localhost  # r2 (AS 200)
ssh -p 2213 cisco@localhost  # r3 (AS 300)
ssh -p 2214 cisco@localhost  # r4 (AS 100)
```

**OSPF Basics Lab:**
```bash
ssh -p 2221 cisco@localhost  # r1
ssh -p 2222 cisco@localhost  # r2
ssh -p 2223 cisco@localhost  # r3
```

**Enterprise VPN Migration Lab:**
```bash
ssh -p 2231 cisco@localhost  # router-a1 (Chicago)
ssh -p 2232 cisco@localhost  # router-a2 (Chicago)
ssh -p 2233 cisco@localhost  # router-b1 (Austin)
ssh -p 2234 cisco@localhost  # router-b2 (Austin)
ssh -p 2235 cisco@localhost  # internet-core (ISP)
```

**All labs**: Password is `cisco`

---

## Expected Behavior

**After rebuild:**
```bash
ssh -p 2211 cisco@localhost
Password: cisco

r1#  # Lands directly in router CLI
r1# show ip bgp summary
```

**NOT:**
```bash
ssh -p 2211 admin@localhost  # ❌ This won't work anymore
Permission denied
```

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
**Symptom**: `ssh -p 2211 admin@localhost` fails

**Cause**: Using old `admin` username

**Solution**: Use new `cisco` username:
```bash
ssh -p 2211 cisco@localhost
```

### Still prompts for old password
**Symptom**: New containers still use `NokiaSrl1!` password

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
- [ ] `./build-frr-ssh.sh` to rebuild with new credentials
- [ ] `clab deploy` labs with new image
- [ ] Test SSH with `cisco/cisco` credentials

---

**Do this now in Codespaces!** Your users expect `cisco/cisco` credentials. 🚀
