# Next Steps - Free Labs Launch Checklist

**Created**: October 2, 2025
**Goal**: Test, validate, and publish free labs to GitHub

---

## Phase 1: Testing & Validation (This Week)

### OSPF Basics Lab
- [ ] Open `ospf-basics/` in VS Code
- [ ] Click "Reopen in Container"
- [ ] Wait for devcontainer build (~2-3 min first time)
- [ ] Run `./scripts/deploy.sh`
  - Expected: Deploys in <30 seconds
  - 3 FRR containers running
- [ ] Run `./scripts/validate.sh`
  - Expected: 6/6 tests pass
- [ ] Test manual exercises from README:
  - [ ] `show ip ospf neighbor` - see 2 Full neighbors
  - [ ] `show ip route ospf` - see learned routes
  - [ ] `show ip ospf database` - see LSAs
  - [ ] Ping test to 192.168.100.1
- [ ] Run `./scripts/cleanup.sh`
  - Expected: Clean shutdown
- [ ] Document any issues found

### BGP eBGP Basics Lab
- [ ] Open `bgp-ebgp-basics/` in VS Code
- [ ] Click "Reopen in Container"
- [ ] Run `./scripts/deploy.sh`
  - Expected: Deploys in <30 seconds
  - 4 FRR containers running
- [ ] Run `./scripts/validate.sh`
  - Expected: 6/6 tests pass
- [ ] Test manual exercises from README:
  - [ ] `show ip bgp summary` - see Established sessions
  - [ ] `show ip bgp` - see AS-paths
  - [ ] Verify AS-path loop prevention
  - [ ] Ping test across AS boundaries
- [ ] Run `./scripts/cleanup.sh`
- [ ] Document any issues found

### Linux Network Namespaces Lab
- [ ] Open `linux-network-namespaces/` in VS Code
- [ ] Click "Reopen in Container"
- [ ] Run `./scripts/deploy.sh`
  - Expected: Deploys in <30 seconds
  - 4 Alpine containers running
- [ ] Run `./scripts/validate.sh`
  - Expected: 5/5 tests pass
- [ ] Test manual exercises from README:
  - [ ] `ip addr show` inside container
  - [ ] `ip route show` inside container
  - [ ] Test IP forwarding on/off
  - [ ] Ping tests between subnets
- [ ] Run `./scripts/cleanup.sh`
- [ ] Document any issues found

---

## Phase 2: Fix Issues (If Any)

### Common Issues to Watch For

**Containerlab deployment fails**:
- Check Docker daemon running
- Check privileged mode in devcontainer
- Verify network=host setting

**FRR containers not starting**:
- Check daemons file permissions
- Verify frr.conf syntax
- Check bind mount paths

**Validation tests failing**:
- Wait 30-60 seconds for protocols to converge
- Check neighbor adjacencies manually
- Verify IP addresses configured correctly

**Devcontainer not building**:
- Check Docker Desktop running
- Verify internet connection (pulls image)
- Check devcontainer.json syntax

### Fix Process
1. Identify issue
2. Update configs/scripts as needed
3. Re-test in devcontainer
4. Update documentation if needed
5. Git commit changes

---

## Phase 3: Finalize for Launch

### Update Main README
- [ ] Add badges (optional):
  - License badge
  - GitHub stars (after publish)
  - Lab count badge
- [ ] Add screenshot/topology diagram (optional)
- [ ] Verify all links work
- [ ] Check markdown formatting

### Create CONTRIBUTING.md (Optional)
```markdown
# Contributing

Thanks for your interest! To contribute:

1. Fork the repo
2. Create a feature branch
3. Test your changes in devcontainer
4. Ensure validation tests pass
5. Submit a Pull Request
```

### Create .github/workflows/validate.yml (Optional CI)
```yaml
name: Validate Labs
on: [push, pull_request]
jobs:
  validate:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      - name: Install containerlab
        run: bash -c "$(curl -sL https://get.containerlab.dev)"
      - name: Test OSPF Lab
        run: cd ospf-basics && ./scripts/deploy.sh && ./scripts/validate.sh
```

---

## Phase 4: Publish to GitHub

### Create Public Repo

```bash
cd /Users/bhunt/development/claude/containerlab-free-labs

# Review files before committing
git status

# Stage all files
git add .

# Create commit
git commit -m "Initial release: Free containerlab network labs

Features:
- 3 comprehensive labs (OSPF, BGP, Linux Namespaces)
- VS Code devcontainer support
- Automated validation tests
- 45-60 minute learning experiences

Each lab includes:
✓ Complete topology.clab.yml
✓ Tested configurations
✓ Automated validation (5-6 tests per lab)
✓ Comprehensive documentation
✓ Deployment/cleanup scripts"

# Create GitHub repo (public)
gh repo create containerlab-free-labs \
  --public \
  --source=. \
  --remote=origin \
  --description="Free containerlab network labs - Learn OSPF, BGP, and Linux networking with hands-on exercises"

# Push to GitHub
git push -u origin main
```

### Post-Publish Tasks

- [ ] Add topics/tags on GitHub:
  - `containerlab`
  - `networking`
  - `network-automation`
  - `ospf`
  - `bgp`
  - `free-labs`
  - `network-learning`

- [ ] Add repo description
- [ ] Enable Issues
- [ ] Enable Discussions (optional)
- [ ] Pin to profile (optional)

---

## Phase 5: Marketing & Promotion

### Reddit Posts

**r/networking**:
```
Title: [Open Source] Free Containerized Network Labs - OSPF, BGP, Linux Namespaces

Body:
I've created 3 free containerized network labs using Containerlab and FRR:

1. OSPF Basics - 3-router topology, single area
2. BGP eBGP Basics - 4 routers, 3 AS design
3. Linux Network Namespaces - Understanding container networking

Each lab includes:
- VS Code devcontainer support (one-click setup)
- Automated validation tests
- Comprehensive documentation
- 45-60 minute hands-on exercises

Why containerlab?
- 75% less memory than GNS3/EVE-NG
- 96% faster startup (30 sec vs 10+ min)
- No VMs needed, just Docker

Repo: [link]

Feedback welcome!
```

**r/ccna** (similar post, tailored for CCNA students)

**r/devops** (focus on automation angle)

### LinkedIn Post

```
🚀 Just released: Free containerized network labs for learning OSPF, BGP, and Linux networking!

3 comprehensive labs with:
✓ One-click VS Code devcontainer setup
✓ Automated validation tests
✓ 75% less resources than traditional VMs
✓ Modern containerlab approach

Perfect for:
- Network engineers learning automation
- Students preparing for CCNA/CCNP
- Anyone wanting hands-on practice without heavy VM setups

Check it out: [GitHub link]

#networking #devops #automation #opensource
```

### Twitter/X Post

```
🎓 Free network labs using @containerlabnet:
- OSPF (3 routers)
- BGP eBGP (4 routers, 3 AS)
- Linux Namespaces (networking 101)

✅ VS Code devcontainers
✅ Automated tests
✅ No VMs needed

Perfect for #CCNA #CCNP practice

[GitHub link]
```

### Hacker News (Show HN)

```
Title: Show HN: Free containerized network labs (OSPF, BGP, Namespaces)

URL: [GitHub repo]
```

---

## Phase 6: Monitor & Iterate

### Week 1 After Launch
- [ ] Monitor GitHub stars/forks
- [ ] Respond to issues quickly
- [ ] Engage with community feedback
- [ ] Fix any bugs reported

### Week 2-4
- [ ] Add contributors (if any)
- [ ] Consider adding more free labs (if popular)
- [ ] Collect user testimonials
- [ ] Update documentation based on feedback

### Month 2-3
- [ ] Publish blog post about the project
- [ ] Create YouTube video walkthrough (optional)
- [ ] Add to Awesome Lists:
  - awesome-containerlab
  - awesome-networking
  - awesome-network-automation

---

## Conversion to Premium Platform

### Add Call-to-Action

In each lab README, add at bottom:

```markdown
---

## 🚀 Want More Advanced Labs?

These free labs are perfect for learning fundamentals. Looking for:

- 🔥 **Real troubleshooting scenarios** with embedded issues
- 🔥 **MPLS, EVPN, SR Linux automation**
- 🔥 **Instant browser-based labs** (no local setup)
- 🔥 **Structured certification tracks**

Check out **[Your Platform Name]** - Professional network labs in your browser.

**Launch Offer**: Use code `GITHUB20` for 20% off your first month!

[Learn More →]
```

### Track Conversions

- Add UTM parameters to links
- Monitor referrals from GitHub
- A/B test different CTAs

---

## Success Metrics

### Week 1
- 10-20 GitHub stars
- 2-5 issues/questions
- 1-2 forks

### Month 1
- 50-100 GitHub stars
- 5-10 contributors (issues/PRs)
- Featured on awesome-lists

### Month 3
- 200+ GitHub stars
- Active community
- Regular contributions
- 1-2% conversion to premium platform

---

*Last Updated: October 2, 2025*
