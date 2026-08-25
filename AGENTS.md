# containerlab-free-labs — working notes for AI agents

Six labs. Each is a disposable Docker topology, rebuilt from `topology.clab.yml` whenever it
breaks. Nothing here is production.

## The contract every lab follows

```bash
cd <lab>
./scripts/deploy.sh      # bring it up
./scripts/validate.sh    # the grader — this decides pass/fail
./scripts/cleanup.sh     # tear down
```

`./scripts/test-all-labs.sh` from the repo root runs everything.

## Labs

| Directory | Nodes | What it exercises |
|---|---|---|
| `linux-network-namespaces/` | 4 alpine | veth pairs, namespaces, bridges |
| `ospf-basics/` | 3 FRR | single-area OSPF, DR/BDR |
| `bgp-ebgp-basics/` | 4 FRR | eBGP across 3 AS, AS-path |
| `vyos-firewall-basics/` | VyOS + 2 alpine | zone-based firewall, NAT |
| `zero-trust-fundamentals/` | docker-compose | JWT auth, identity-based access |
| `enterprise-vpn-migration/` | 16 mixed | 2-site GRE VPN migration with rollback |

Each lab has its own mgmt network and subnet (`clab-ospf/.22`, `clab-bgp/.23`, `clab-vyos/.24`,
`clab-vpn/.25`, `clab-netns/.21`), so several can run at once without colliding.

## Reaching routers

FRR routers accept SSH on published ports and land at the router CLI. **Scripted access works**,
which is what makes them agent-drivable:

```bash
ssh -p 2221 admin@localhost "show ip ospf neighbor"     # admin / cisco
```

| Lab | Routers | Ports |
|---|---|---|
| ospf-basics | r1–r3 | 2221–2223 |
| bgp-ebgp-basics | r1–r4 | 2211–2214 |
| enterprise-vpn-migration | router-a1/a2, router-b1/b2, internet-core | 2231–2235 |

`admin` has no shell — it is the router CLI. For `tcpdump`, file edits or `scp`, use `labshell`
(same password). Direct container access: `docker exec -it clab-<lab>-<node> vtysh`.

**Careful on a Mac:** if `docker ps` does not list the `clab-*` containers, your `docker` CLI is
pointed at a different engine than the one running the labs. Check `docker context ls`. The
sibling repo `srl-agent-labs` solves this generally with a `labctl` shim.

## Platform notes

- FRR labs are arm64-native (`quay.io/frrouting/frr:10.4.4` multi-arch) — no emulation on Apple Silicon.
- The VyOS image is amd64-only, and the lab needs `br_netfilter` loaded on the host or the
  firewall silently permits everything. `scripts/deploy.sh` loads it.

## If you change validation

A check that cannot fail is worse than no check — it reports success. Before trusting a green
run, break the lab on purpose and confirm the check goes red. This repo shipped a CI that was
green for months while printing `✗ SSH access failed`, because the check used
`<cmd> && echo ok || echo failed` and the failure never reached the exit status.

When you fix a bug in one lab, grep the other five for the same pattern. Three defects in
`enterprise-vpn-migration` were bugs already fixed in sibling labs a year earlier and never
backported.

## Not for agent use

`dev-docs-system/` and several `.claude/commands/` are a verbatim import from a Laravel/React
project — `/test` runs PHPUnit, `/build` references Inertia.js. They do not apply to this repo.
Ignore them until they are retargeted.
