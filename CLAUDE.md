# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

Containerlab-based network labs using FRRouting (FRR) for learning OSPF, BGP, and Linux networking fundamentals. Labs run in Docker containers with ~75% less memory than VM-based alternatives.

## Common Commands

### First-Time Setup
```bash
# Build the frr-ssh image (required before running any lab)
./build-frr-ssh.sh
```

### Running Labs
```bash
# Deploy a lab (requires sudo)
cd <lab-name>
sudo containerlab deploy -t topology.clab.yml

# Or use the deploy script
./scripts/deploy.sh

# Cleanup
sudo containerlab destroy -t topology.clab.yml
# Or: ./scripts/cleanup.sh
```

### Router Access
```bash
# SSH access (preferred - lands directly at router CLI)
ssh -p <port> admin@localhost  # Password: cisco

# Docker exec (alternative)
docker exec -it clab-<lab-name>-<router> vtysh
```

### Validation
```bash
# Run lab tests
./scripts/validate.sh
```

## Lab Structure

Each lab follows this structure:
```
<lab-name>/
├── topology.clab.yml    # Containerlab topology definition
├── configs/             # FRR configs per router (daemons, frr.conf)
├── scripts/
│   ├── deploy.sh       # Deployment wrapper
│   ├── validate.sh     # Automated tests
│   └── cleanup.sh      # Teardown script
└── README.md           # Lab guide with exercises
```

## Architecture

- **frr-ssh image**: Custom FRR image built by `build-frr-ssh.sh` that adds SSH access with auto-login to vtysh (admin/cisco credentials)
- **Topology files**: YAML files defining nodes (routers) and links, with port mappings for SSH access
- **Container naming**: `clab-<topology-name>-<node-name>` (e.g., `clab-ospf-basics-r1`)

## SSH Port Mapping by Lab

| Lab | Router Ports |
|-----|--------------|
| ospf-basics | r1:2221, r2:2222, r3:2223 |
| bgp-ebgp-basics | r1:2211, r2:2212, r3:2213, r4:2214 |

## Validation Test Pattern

Tests use `docker exec` with `vtysh -c` to verify:
- Protocol neighbor states (OSPF Full, BGP Established)
- Route propagation
- End-to-end connectivity (ping tests)

## CI/CD

GitHub Actions workflow (`.github/workflows/validate-labs.yml`) runs on push/PR to main. Each lab job:
1. Installs containerlab
2. Builds frr-ssh image
3. Deploys topology
4. Waits for protocol convergence (30-60s)
5. Runs validation tests
6. Cleans up

## Dev-Docs System

Portable development documentation system in `dev-docs-system/` for strategic planning and context preservation.

### Key Commands
- `/dev-docs "feature description"` - Create strategic plan with dev docs
- `/dev-docs-update "feature-name"` - Update docs at session end
- `/code-review "feature-name"` - Validate code against plan

### Components
- **Commands** (`commands/`): 11 slash commands for planning, updating, and reviewing
- **Hooks** (`hooks/`): Stop event for error detection, skill auto-activation
- **Agents** (`agents/`): Strategic plan architect, build error resolver, and 5 more
- **Templates** (`templates/`): Plan, context, and tasks file templates

### Usage
```bash
# Create strategic plan for a new feature
/dev-docs "Add MPLS L3VPN lab"

# Output: dev/active/mpls-l3vpn/
#   ├── mpls-l3vpn-plan.md      # Architecture & phases
#   ├── mpls-l3vpn-context.md   # Decisions & discoveries
#   └── mpls-l3vpn-tasks.md     # Task checklist
```

See `dev-docs-system/README.md` for installation and `dev-docs-system/SETUP.md` for configuration.
