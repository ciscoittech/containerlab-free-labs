# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Added
- **Enterprise VPN Migration Lab** (2025-10-05) - 16-container real-world scenario
  - Simulates site-to-site VPN IP migration with minimal downtime
  - 2 sites: Chicago HQ (Site A) and Austin remote office (Site B)
  - 5 FRR routers with OSPF and BGP
  - 2 VyOS zone-based firewalls
  - 7 Alpine Linux services (nginx, dnsmasq, OpenLDAP)
  - 2 monitoring platforms (Grafana, Netbox)
  - 22 automated validation tests covering infrastructure, routing, VPN, and services
  - Complete migration runbook with risk assessment and rollback procedures
  - GRE tunnel migration scenario: `203.0.113.x ↔ 198.51.100.x` → `192.0.2.10 ↔ 192.0.2.20`
  - Path: `enterprise-vpn-migration/`

### Fixed
- Alpine container shell compatibility in Enterprise VPN Migration Lab
  - Changed `cmd: bash` to `cmd: sh` for Alpine Linux compatibility
  - Fixes 7 Alpine containers that failed to start
- Container image versions in Enterprise VPN Migration Lab
  - Updated FRR image from `frrouting/frr:9.1.0` to `frrouting/frr:latest`
  - Updated VyOS image from `vyos/vyos:1.4-rolling-202310260023` to `ghcr.io/sever-sever/vyos-container:latest`
  - Ensures all images exist and can be pulled successfully

## [1.0.0] - 2025-10-02

### Added
- Initial release of free containerlab network labs
- Three foundational network labs:
  - OSPF Basics Lab (4-router topology)
  - BGP eBGP Basics Lab (2-AS, 4-router topology)
  - Linux Network Namespaces Lab (educational/reference)
- GitHub Codespaces support with one-click deployment button
- Comprehensive quick start guide for new users
- Manual testing log template for lab validation
- Comprehensive testing instructions for all 3 labs
- Project metrics and KPI tracking system
- CI/CD pipeline with GitHub Actions
- Devcontainer configuration following official containerlab Codespaces guide

### Changed
- Updated devcontainer to use containerlab's official Codespaces configuration
- Enhanced Codespaces button with custom styling
- Updated CI badge URL to use ciscoittech username

### Removed
- Business and marketing related documentation (pivoted to 100% free/open source)
- Paid tier mentions from QUICK-START-GUIDE
- Business pitch section from README
- All business/premium mentions from lab READMEs

## Project Links
- [Repository](https://github.com/ciscoittech/containerlab-free-labs)
- [Issues](https://github.com/ciscoittech/containerlab-free-labs/issues)
- [Discussions](https://github.com/ciscoittech/containerlab-free-labs/discussions)
