# Free Containerlab Network Labs

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![Labs](https://img.shields.io/badge/labs-6-blue.svg)](.)
[![Containerlab](https://img.shields.io/badge/containerlab-latest-green.svg)](https://containerlab.dev/)
[![CI](https://github.com/ciscoittech/containerlab-free-labs/workflows/Validate%20Labs/badge.svg)](https://github.com/ciscoittech/containerlab-free-labs/actions)

**Hands-on network labs that run in seconds, not hours.** Built with [Containerlab](https://containerlab.dev/) and [FRR](https://frrouting.org/) so you can practice real routing protocols without expensive hardware or heavy VMs.

[![Run in Codespaces](.github/images/open-in-codespaces.svg)](https://codespaces.new/ciscoittech/containerlab-free-labs?quickstart=1)

> **Recommended: Use [Damira AI](https://damiraai.com) alongside these labs** — a free AI assistant for network engineers. Paste your output, describe what's broken, get the diagnosis. No credit card, [sign up in 30 seconds](https://damiraai.com). Each lab includes Damira prompts you can try. In Codespaces, it's pre-installed — see [DAMIRA_SETUP.md](DAMIRA_SETUP.md). Having trouble? [Open an issue](https://github.com/ciscoittech/containerlab-free-labs/issues).

---

## What's This?

If you've ever spent hours setting up GNS3 or EVE-NG just to practice OSPF, this is for you. Each lab spins up a full network topology using Docker containers in about 30 seconds. You get real router CLIs, real routing protocols, and real troubleshooting — without the overhead.

**How it compares:**

| | Containerlab (this repo) | GNS3 / EVE-NG |
|---|---|---|
| Memory per router | ~50 MB | 1 GB+ |
| Startup time | ~30 seconds | 10+ minutes |
| Setup | `git clone` + one command | Download ISOs, configure VMs, pray |
| Cost | Free | Free (but needs beefy hardware) |

Perfect for CCNA, CCNP, and anyone learning network engineering.

---

## Labs

Six labs, beginner to advanced. Each one includes automated validation so you know when you've got it right.

| Lab | Level | Time | What You'll Learn |
|-----|-------|------|-------------------|
| [Linux Network Namespaces](linux-network-namespaces/) | Beginner | 30 min | How containers create isolated networks under the hood |
| [OSPF Basics](ospf-basics/) | Beginner | 45 min | Single-area OSPF, neighbor adjacency, DR/BDR election |
| [BGP eBGP Basics](bgp-ebgp-basics/) | Beginner | 60 min | eBGP peering across 3 autonomous systems, AS-path |
| [VyOS Firewall Basics](vyos-firewall-basics/) | Beginner | 45 min | Zone-based firewall, traffic filtering, NAT |
| [Zero Trust Fundamentals](zero-trust-fundamentals/) | Intermediate | 45 min | JWT auth, microservices, identity-based access |
| [Enterprise VPN Migration](enterprise-vpn-migration/) | Advanced | 90 min | 16-container, 2-site GRE VPN migration with rollback |

### Recommended order

Start at the top and work your way down. Each lab builds on concepts from the previous ones.

1. **Linux Namespaces** — understand how containerlab works under the hood
2. **OSPF** — your first routing protocol
3. **BGP** — how the internet routes traffic between networks
4. **Firewall** — add security between zones
5. **Zero Trust** — modern identity-based access control
6. **Enterprise VPN** — put it all together in a real-world migration scenario

---

## Quick Start

### Option 1: GitHub Codespaces (easiest)

Click the button above. That's it. Everything is pre-installed.

### Option 2: Run locally

```bash
# Install containerlab (Linux or Mac)
bash -c "$(curl -sL https://get.containerlab.dev)"

# Clone and build
git clone https://github.com/ciscoittech/containerlab-free-labs.git
cd containerlab-free-labs
./build-frr-ssh.sh    # builds the router image (first time only)

# Pick a lab and deploy
cd ospf-basics
sudo containerlab deploy -t topology.clab.yml

# SSH into a router — you'll land right at the CLI
ssh -p 2221 admin@localhost
# Password: cisco

# When you're done
sudo containerlab destroy -t topology.clab.yml
```

### Accessing Routers

Every FRR router has SSH enabled. Login and you land directly at the router CLI, just like a real Cisco or Juniper box.

```
$ ssh -p 2221 admin@localhost
Password: cisco

r1# show ip ospf neighbor
r1# show ip route
r1# show ip bgp summary
```

**Credentials:** `admin` / `cisco`

You can also connect via VS Code (right-click container, SSH) or Docker exec (`docker exec -it clab-ospf-basics-r1 vtysh`).

---

---

## Who This Is For

- **CCNA / CCNP students** — practice routing protocols with Cisco-like CLI syntax
- **Network engineers** — spin up quick topologies to test ideas
- **Career switchers** — learn networking hands-on without buying hardware
- **Instructors** — give students lab environments that just work

## Contributing

Got an idea for a lab? Found a bug? PRs are welcome.

1. Fork this repo
2. Create a branch (`git checkout -b feature/my-lab`)
3. Test with the validation scripts (`./scripts/validate.sh`)
4. Open a PR

See [CONTRIBUTING.md](CONTRIBUTING.md) for details.

## Resources

- [Containerlab Docs](https://containerlab.dev/) — the tool that makes this possible
- [FRRouting Docs](https://docs.frrouting.org/) — the routing suite behind the router CLIs
- [Codespaces Guide](README-CODESPACES.md) — detailed setup for GitHub Codespaces

## License

MIT — use these labs for learning, teaching, corporate training, whatever you want.
