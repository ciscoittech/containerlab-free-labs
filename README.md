# Free Containerlab Network Labs

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![Labs](https://img.shields.io/badge/labs-6-blue.svg)](.)
[![Containerlab](https://img.shields.io/badge/containerlab-latest-green.svg)](https://containerlab.dev/)
[![CI](https://github.com/ciscoittech/containerlab-free-labs/workflows/Validate%20Labs/badge.svg)](https://github.com/ciscoittech/containerlab-free-labs/actions)

**Hands-on network labs that run in seconds, not hours.** Built with [Containerlab](https://containerlab.dev/) and [FRR](https://frrouting.org/) so you can practice real routing protocols without expensive hardware or heavy VMs.

[![Run in Codespaces](.github/images/open-in-codespaces.svg)](https://codespaces.new/ciscoittech/containerlab-free-labs?quickstart=1)

### Run the labs with an AI network engineer

**The future of network engineering is agentic.** AI agents that diagnose faults, generate configs, and troubleshoot alongside you aren't coming — they're here. Engineers who learn to work with them now will lead the teams that depend on them later.

**[Damira AI](https://damiraai.com)** is a network operations assistant that runs inside your editor. In Cursor it installs in about 60 seconds, no signup:

```bash
agent plugin marketplace add https://github.com/ciscoittech/damira-plugins
```

Then `/plugins` in the agent (or **Settings → Plugins**) and install **damira**. A shared demo key is built in — 50 queries/day, no credit card.

By default Damira runs in **advisor mode**: it hands you the exact commands and reads the output you paste back. That is the correct setting against a production network. These labs are not production, so you can let it drive instead:

```bash
export DAMIRA_EXECUTION_MODE=lab    # this shell only — see the warning below
```

In lab mode it opens the SSH sessions itself, runs the `show` commands, and works a fault down to root cause while you watch. Give it the whole problem — *"R1 has no OSPF neighbors, I'm in ospf-basics"* — instead of a pasted routing table. That supervision loop is the actual skill worth practicing.

> ⚠️ **Export `DAMIRA_EXECUTION_MODE` per shell — never in `~/.zshrc` or `~/.bashrc`.**
> Lab mode is the switch that lets the agent open SSH sessions at all; a plugin hook blocks
> them otherwise. Leave it set globally and the guard is also off the next morning when
> you're on a real network. Advisor mode is the default for a reason.

Using Codespaces, VS Code, or Claude Code instead? See [DAMIRA_SETUP.md](DAMIRA_SETUP.md).

*Having trouble with Damira? [Open an issue](https://github.com/ciscoittech/containerlab-free-labs/issues) — we respond fast.*

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

Every lab has its own management network and subnet, so you can leave one deployed while you start the next. Nothing collides.

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
./scripts/deploy.sh

# SSH into a router — you'll land right at the CLI
ssh -p 2221 admin@localhost
# Password: cisco

# Check your work
./scripts/validate.sh

# When you're done
./scripts/cleanup.sh
```

Every lab follows the same three scripts: `deploy.sh`, `validate.sh`, `cleanup.sh`. CI runs each lab's full validation suite on every push, so a green badge means the assertions actually ran and actually passed.

### Requirements

- Docker and [containerlab](https://containerlab.dev/) on Linux, or Docker Desktop / [OrbStack](https://orbstack.dev/) on macOS
- ~2 GB free RAM for the small labs, ~4 GB for the 16-container VPN migration

**Apple Silicon:** the FRR router image is built from a multi-arch base (`quay.io/frrouting/frr:10.4.4`), so the five FRR-based labs run natively on M-series Macs — no emulation.

**VyOS firewall lab:** the VyOS container image is `linux/amd64` only, so on Apple Silicon it runs under emulation or not at all. It also needs the `br_netfilter` kernel module on the host — VyOS sets `net.bridge.bridge-nf-call-*` on every firewall commit, and those sysctl keys don't exist until the module is loaded. Without it the commit fails silently and the firewall permits everything. `scripts/deploy.sh` loads it for you:

```bash
sudo modprobe br_netfilter
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

| Lab | Routers | SSH ports |
|-----|---------|-----------|
| OSPF Basics | r1–r3 | 2221–2223 |
| BGP eBGP Basics | r1–r4 | 2211–2214 |
| Enterprise VPN Migration | router-a1/a2, router-b1/b2, internet-core | 2231–2235 |

Scripted access works the same way, which is what CI checks on every run — and what lets an AI assistant in lab mode read device state for itself:

```bash
ssh -p 2221 admin@localhost "show ip ospf neighbor"
```

**Need a Linux shell on the box** — `tcpdump`, editing files, `scp`, VS Code Remote-SSH?
`admin` is the router CLI and has no shell, so use the `labshell` account instead:

```bash
ssh -p 2221 labshell@localhost     # password: cisco
```

Or go in directly with Docker: `docker exec -it clab-ospf-basics-r1 vtysh` (router CLI)
or `docker exec -it clab-ospf-basics-r1 bash` (shell).

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
3. Test it (`cd <lab> && ./scripts/validate.sh`, or `./scripts/test-all-labs.sh` for everything)
4. Open a PR

A validation script that can't fail is worse than no validation script. If you add checks, make sure a broken lab actually turns them red. See [CONTRIBUTING.md](CONTRIBUTING.md) for details.

## Resources

- [Containerlab Docs](https://containerlab.dev/) — the tool that makes this possible
- [FRRouting Docs](https://docs.frrouting.org/) — the routing suite behind the router CLIs
- [Codespaces Guide](README-CODESPACES.md) — detailed setup for GitHub Codespaces
- [Damira AI setup](DAMIRA_SETUP.md) — using the AI assistant with these labs

## License

MIT — use these labs for learning, teaching, corporate training, whatever you want.
