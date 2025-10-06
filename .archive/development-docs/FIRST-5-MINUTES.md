# Get a Lab Running in 5 Minutes ⚡

**Goal**: Working network lab in your browser with ZERO installation

**Method**: GitHub Codespaces (cloud-based VS Code)

---

## Step 1: Click This Button (30 seconds)

Visit the repository: **https://github.com/ciscoittech/containerlab-free-labs**

Click the green button:
```
┌──────────────────────────────────────┐
│  ▶ Open in GitHub Codespaces        │
└──────────────────────────────────────┘
```

**What happens**: GitHub starts creating a cloud environment for you

---

## Step 2: Wait for Setup (2-3 minutes)

You'll see:
```
Setting up your codespace...
Running postCreateCommand...
```

**What's happening**:
- Installing containerlab
- Downloading network container images
- Setting up Docker-in-Docker

**Just wait** - this is automatic!

✅ **Done when**: Terminal appears with prompt `root@codespace:/workspaces/containerlab-free-labs#`

---

## Step 3: Choose a Lab (10 seconds)

**Type this**:
```bash
cd linux-network-namespaces
```

**Why this lab**: Simplest, fastest (30 min to complete)

---

## Step 4: Deploy the Lab (30 seconds)

**Type this**:
```bash
./scripts/deploy.sh
```

**You'll see**:
```
=========================================
Deploying Linux Network Namespaces Lab
=========================================

INFO[0002] Creating container: "host1"
INFO[0003] Creating container: "host2"
INFO[0004] Creating container: "router"
INFO[0005] Creating container: "host3"

Lab Deployed Successfully!
=========================================
```

**Duration**: 15-30 seconds

---

## Step 5: Verify It Works (5 seconds)

**Type this**:
```bash
./scripts/validate.sh
```

**You'll see**:
```
Test 1: host1 -> router connectivity...
  ✓ PASSED

Test 2: host2 -> router connectivity...
  ✓ PASSED

Test 3: host1 <-> host2 connectivity...
  ✓ PASSED

Test 4: IP forwarding on router...
  ✓ PASSED

Test 5: host1 -> host3 connectivity...
  ✓ PASSED

========================================
Tests Passed: 5
Tests Failed: 0

✓ All tests passed! Lab is working correctly.
```

---

## 🎉 SUCCESS!

You now have a working network lab with:
- 4 containers (3 hosts + 1 router)
- 2 subnets (10.0.1.0/24 and 10.0.2.0/24)
- IP routing between them

**Total time**: ~5 minutes

---

## What To Do Next (Optional)

### Explore a Container (30 seconds)
```bash
docker exec -it clab-netns-basics-host1 sh
```

Inside container:
```bash
ip addr show       # See IP address
ip route show      # See routing table
ping -c 3 10.0.2.10   # Ping across subnets
exit              # Leave container
```

### Read the Lab Guide (30 minutes)
```bash
cat README.md
```

Follow exercises to learn:
- What are network namespaces?
- How do containers get isolated networks?
- How does routing work between subnets?

### Try Another Lab (45-60 minutes)
```bash
cd ../ospf-basics
./scripts/deploy.sh
./scripts/validate.sh
```

Learn OSPF routing protocol with 3 routers!

---

## Cleanup (When Done)
```bash
./scripts/cleanup.sh
```

Removes all containers (can redeploy anytime)

---

## Common Issues

### "Permission denied"
- **Problem**: Not in Codespaces
- **Check**: Bottom-left corner of VS Code should say "Codespaces"
- **Fix**: Make sure you clicked "Open in Codespaces" button

### "Command not found: containerlab"
- **Problem**: Setup not complete yet
- **Wait**: Another 1-2 minutes for `postCreateCommand` to finish
- **Check**: Type `containerlab version` - should work when ready

### Tests fail
- **Problem**: Protocols need more time to converge
- **Wait**: 60 seconds
- **Retry**: `./scripts/validate.sh`

---

## Why This Works

**Codespaces gives you**:
- Cloud-based VS Code (in browser)
- Docker-in-Docker (run containers inside container!)
- Containerlab pre-installed
- 60 hours free/month (GitHub Free plan)

**No local installation needed**:
- No Docker Desktop download
- No VS Code setup
- No containerlab installation
- Works on ANY computer (even Chromebook!)

---

## Next Steps

1. ✅ **You've completed**: First lab deployment
2. 📖 **Read**: [NEW-USER-JOURNEY.md](NEW-USER-JOURNEY.md) for detailed paths
3. 🎓 **Learn**: Complete all 3 labs (Linux Namespaces → OSPF → BGP)
4. 🔨 **Experiment**: Modify configs, break things, learn by doing!

---

**Time invested**: 5 minutes
**Skills gained**: Container networking, network namespaces, lab deployment
**Next lab**: OSPF Basics (45 min)

---

*Last Updated: October 3, 2025*
*Having trouble? Check [PITFALLS-AND-FIXES.md](PITFALLS-AND-FIXES.md)*
