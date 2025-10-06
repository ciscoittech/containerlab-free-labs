# GitHub Codespaces Quick Start 🚀

**First time setup in Codespaces? Do this first!**

---

## Step 1: Build the FRR SSH Image

The labs require a custom `frr-ssh:latest` image with SSH auto-login enabled.

**Run this command in Codespaces terminal:**
```bash
./build-frr-ssh.sh
```

Takes ~2-3 minutes first time. Output should end with:
```
✅ frr-ssh:latest image built successfully!
✅ Ready to deploy labs!
```

---

## Step 2: Deploy a Lab

**BGP eBGP Basics Lab:**
```bash
cd bgp-ebgp-basics
clab deploy -t topology.clab.yml
```

Wait 10 seconds for FRR daemons to start:
```bash
sleep 10
```

---

## Step 3: Test SSH Auto-Login

**SSH to router r1:**
```bash
ssh -p 2211 cisco@localhost
# Password: cisco
```

**Expected:** You land DIRECTLY at the router CLI:
```
r1#
```

**Try commands:**
```
r1# show ip bgp summary
r1# show ip route
r1# configure terminal
r1(config)#
```

**Exit:**
```
r1# exit
```

---

## All Labs Available

After building `frr-ssh:latest` once, you can deploy any lab:

**BGP Labs:**
- `bgp-ebgp-basics/` - 4 routers, multi-AS eBGP (SSH ports 2211-2214)

**OSPF Labs:**
- `ospf-basics/` - 3 routers, single-area OSPF (SSH ports 2221-2223)

**Enterprise Labs:**
- `enterprise-vpn-migration/` - 16 containers, VPN migration (SSH ports 2231-2235)

---

## SSH Access

All FRR routers have SSH enabled with **auto-login to CLI**:
- Username: `cisco`
- Password: `cisco`
- Behavior: Lands directly in `router#` prompt (like real Cisco/Juniper routers)

---

## Troubleshooting

### Image not found error
```
Error: No such image: frr-ssh:latest
```

**Solution:** Run `./build-frr-ssh.sh` first

### Mount errors during deploy
```
error mounting "/workspaces/.../configs/r1/daemons"
```

**Solution:** The frr-ssh image needs rebuilding. Run `./build-frr-ssh.sh`

### Containers fail to start
Check if image was built:
```bash
docker images | grep frr-ssh
```

Should show:
```
frr-ssh    latest    <timestamp>    ~170MB
```

### SSH lands in bash instead of router CLI
Old image - rebuild:
```bash
./build-frr-ssh.sh
clab destroy -t topology.clab.yml --cleanup
clab deploy -t topology.clab.yml
```

---

## Cleanup

**Destroy a lab:**
```bash
clab destroy -t topology.clab.yml --cleanup
```

**Remove all containers:**
```bash
docker rm -f $(docker ps -aq)
```

**Remove frr-ssh image (to force rebuild):**
```bash
docker rmi frr-ssh:latest
```

---

## What Makes This Special

✅ **Auto-Login CLI** - SSH drops you directly into router CLI (not bash)
✅ **Authentic Experience** - Behaves exactly like real network gear
✅ **Browser-Based** - Works perfectly in Codespaces terminal
✅ **Multi-User Ready** - Unique SSH ports per router
✅ **Production-Like** - Real FRR routing stack with full protocols

---

## Quick Command Reference

```bash
# Build image (one time)
./build-frr-ssh.sh

# Deploy lab
cd bgp-ebgp-basics && clab deploy -t topology.clab.yml

# SSH to routers
ssh -p 2211 cisco@localhost  # r1
ssh -p 2212 cisco@localhost  # r2
ssh -p 2213 cisco@localhost  # r3
ssh -p 2214 cisco@localhost  # r4

# Destroy lab
clab destroy -t topology.clab.yml --cleanup
```

---

**Ready to start!** Build the image and deploy your first lab. 🎉
