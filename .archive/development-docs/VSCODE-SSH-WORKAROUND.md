# VS Code Containerlab Extension - SSH Credentials

**Status**: ✅ RESOLVED - Credentials changed to `admin/cisco` for compatibility

**Date Updated**: 2025-10-06

---

## The Solution

Changed credentials from `cisco/cisco` to `admin/cisco` to match VS Code extension behavior:
- **Username**: `admin` (matches VS Code extension default)
- **Password**: `cisco` (simple and memorable)

When you right-click a container in VS Code Containerlab extension and select "SSH":
- **What it does**: `ssh admin@clab-bgp-ebgp-basics-r1`
- **What you enter**: Password `cisco`
- **Result**: Lands directly at router CLI (`r1#`)

No workaround needed - credentials now align with extension!

---

## SSH Access Methods

### Option 1: VS Code Extension (Recommended)

1. Right-click container in VS Code
2. Select "SSH"
3. Press Enter (no editing needed!)
4. Password: `cisco`
5. Lands at router CLI: `r1#`

### Option 2: Port Mapping

Use terminal with port forwarding:

```bash
ssh -p 2211 admin@localhost  # r1
ssh -p 2212 admin@localhost  # r2
ssh -p 2213 admin@localhost  # r3
ssh -p 2214 admin@localhost  # r4
```

Password: `cisco`

### Option 3: SSH Aliases (Optional)

Add to your `~/.ssh/config` in Codespaces:

```bash
Host r1
    HostName localhost
    Port 2211
    User admin

Host r2
    HostName localhost
    Port 2212
    User admin

Host r3
    HostName localhost
    Port 2213
    User admin

Host r4
    HostName localhost
    Port 2214
    User admin
```

Then just type:
```bash
ssh r1  # Password: cisco
ssh r2  # Password: cisco
```

### Option 4: Direct Container SSH

Use container names directly:

```bash
ssh admin@clab-bgp-ebgp-basics-r1  # Password: cisco
ssh admin@clab-bgp-ebgp-basics-r2  # Password: cisco
ssh admin@clab-bgp-ebgp-basics-r3  # Password: cisco
ssh admin@clab-bgp-ebgp-basics-r4  # Password: cisco
```

---

## What Changed (History)

**2025-10-06**: Final solution implemented

✅ **Changed credentials to `admin/cisco`** - Matches VS Code extension default
✅ **Updated all Dockerfiles** - User `admin`, password `cisco`
✅ **Updated all documentation** - Consistent `admin@localhost` throughout
✅ **Rebuilt frr-ssh image** - Ready for deployment
✅ **No workarounds needed** - Everything works seamlessly

**Previous attempts:**
- Tried `cisco/cisco` credentials - Conflicted with VS Code extension showing `admin@`
- Tried `CLAB_SSH_CONNECTION` env var - Extension ignores it
- Tried topology labels - Extension doesn't read them

**Root cause identified:**
- VS Code Containerlab extension hardcodes `admin` username for SSH
- Solution: Change our credentials to match extension, not fight it

---

## What Works Now

✅ **VS Code right-click SSH**: Works perfectly with `admin` user
✅ **Port mapping**: `ssh -p 2211 admin@localhost` (password: `cisco`)
✅ **Container name SSH**: `ssh admin@clab-bgp-ebgp-basics-r1` (password: `cisco`)
✅ **Auto-login to router CLI**: Lands at `r1#` immediately after password
✅ **Simple password**: Just type `cisco` - easy to remember

---

## For Users

**SSH is now seamless!**

1. Right-click any container in VS Code Containerlab extension
2. Click "SSH"
3. Press Enter (no editing needed)
4. Type password: `cisco`
5. You're at the router CLI: `r1#`

That's it! No workarounds, no quirks. 🚀
