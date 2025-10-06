# 🚨 CRITICAL FIX - REBUILD REQUIRED

**Issue Found**: SSH was landing at bash shell (`r1:~$`) instead of router CLI (`r1#`)

**Root Cause**: Used `.bashrc` instead of `.bash_profile` for SSH login shells

**Status**: ✅ **FIXED** - Updated `build-frr-ssh.sh` to use `.bash_profile`

---

## You Must Rebuild in Codespaces!

**Run these commands in your Codespaces terminal:**

```bash
# 1. Pull latest fix
git pull

# 2. Destroy existing lab
cd bgp-ebgp-basics
clab destroy -t topology.clab.yml --cleanup

# 3. Remove old image
docker rmi frr-ssh:latest

# 4. Rebuild with fix
cd /workspaces/containerlab-free-labs
./build-frr-ssh.sh

# 5. Deploy lab again
cd bgp-ebgp-basics
clab deploy -t topology.clab.yml

# 6. Wait for FRR to start
sleep 10

# 7. Test SSH - should land at r1# now!
ssh -p 2211 cisco@localhost
# Password: cisco
```

---

## Expected Result

**Before (broken):**
```bash
ssh -p 2211 cisco@localhost
r1:~$  # ❌ Wrong - bash shell
```

**After (fixed):**
```bash
ssh -p 2211 cisco@localhost
r1#  # ✅ Correct - router CLI!
r1# show ip bgp summary
r1# show ip route
```

---

## What Changed

**Old (broken):**
- Used `/home/admin/.bashrc` for auto-vtysh
- Only works for interactive shells
- SSH creates login shells, which don't source `.bashrc`

**New (fixed):**
- Uses `/home/admin/.bash_profile` for auto-vtysh
- Works for login shells (what SSH creates)
- Auto-vtysh executes immediately on SSH login

---

## Quick Test

After rebuilding:

```bash
ssh -p 2211 cisco@localhost
# Password: cisco

# You should IMMEDIATELY see:
r1#

# NOT:
r1:~$
```

If you still see `r1:~$`, check that you:
1. Pulled latest code (`git pull`)
2. Removed old image (`docker rmi frr-ssh:latest`)
3. Rebuilt image (`./build-frr-ssh.sh`)
4. Redeployed lab (`clab destroy`, then `clab deploy`)

---

**Do this now!** Your users need the router CLI experience. 🚀
