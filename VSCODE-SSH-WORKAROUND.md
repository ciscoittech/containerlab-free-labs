# VS Code Containerlab Extension - SSH Workaround

**Issue**: VS Code Containerlab extension right-click SSH uses `admin` instead of `cisco`

**Status**: ⚠️ VS Code extension limitation - Cannot override default user via topology config

---

## The Problem

When you right-click a container in VS Code Containerlab extension and select "SSH":
- **What it does**: `ssh admin@clab-bgp-ebgp-basics-r1`
- **What you need**: `ssh cisco@clab-bgp-ebgp-basics-r1`

The VS Code Containerlab extension appears to have `admin` hardcoded as the default SSH user.

---

## Workarounds

### Option 1: Edit the Command Before Running (Recommended)

1. Right-click container → Select "SSH"
2. **Before pressing Enter**, edit the command in terminal
3. Change `admin@` to `cisco@`
4. Press Enter
5. Password: `cisco`

### Option 2: Use Port Mapping (Easiest)

Instead of clicking in VS Code, use the terminal:

```bash
ssh -p 2211 cisco@localhost  # r1
ssh -p 2212 cisco@localhost  # r2
ssh -p 2213 cisco@localhost  # r3
ssh -p 2214 cisco@localhost  # r4
```

Password: `cisco`

### Option 3: Create SSH Aliases

Add to your `~/.ssh/config` in Codespaces:

```bash
Host r1
    HostName localhost
    Port 2211
    User cisco

Host r2
    HostName localhost
    Port 2212
    User cisco

Host r3
    HostName localhost
    Port 2213
    User cisco

Host r4
    HostName localhost
    Port 2214
    User cisco
```

Then just type:
```bash
ssh r1  # Password: cisco
ssh r2  # Password: cisco
```

### Option 4: Direct Container SSH (Works!)

Use container names directly with correct user:

```bash
ssh cisco@clab-bgp-ebgp-basics-r1  # Password: cisco
ssh cisco@clab-bgp-ebgp-basics-r2  # Password: cisco
ssh cisco@clab-bgp-ebgp-basics-r3  # Password: cisco
ssh cisco@clab-bgp-ebgp-basics-r4  # Password: cisco
```

---

## What We Tried

✅ Added `CLAB_SSH_CONNECTION: cisco@%h:%p` to topology - **Didn't work**
✅ Added labels to topology - **VS Code extension ignores them**
✅ Updated deploy.sh scripts - **Fixed output messages**
✅ Updated all documentation - **READMEs now correct**

❌ **VS Code extension appears to hardcode 'admin' user**

---

## Recommended for Your Users

**Document in lab instructions:**

> **SSH Access Note**: When using VS Code Containerlab extension right-click SSH, the default command shows `admin@`. Simply edit it to `cisco@` before pressing Enter.
>
> **Easier alternative**: Use port mapping commands:
> ```bash
> ssh -p 2211 cisco@localhost  # Password: cisco
> ```

---

## What Actually Works

✅ **Port mapping**: `ssh -p 2211 cisco@localhost`
✅ **Container name**: `ssh cisco@clab-bgp-ebgp-basics-r1`
✅ **Auto-login to router CLI**: Once connected, you land at `r1#` immediately
✅ **Password**: Simple `cisco` instead of complex password

---

## For VS Code Extension Developers

If the Containerlab extension is updated to support custom SSH users, the topology files already have:

```yaml
topology:
  defaults:
    env:
      CLAB_SSH_CONNECTION: cisco@%h:%p
```

This would tell the extension to use `cisco` user.

---

**Bottom Line**: Users can easily work around this by:
1. Using port mapping: `ssh -p 2211 cisco@localhost`
2. Or editing the VS Code command before running it

Not a blocker - just a minor inconvenience. 🚀
