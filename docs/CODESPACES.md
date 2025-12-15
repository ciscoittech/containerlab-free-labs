# Running Labs in GitHub Codespaces

This guide covers running containerlab network labs in GitHub Codespaces.

## Resource Constraints

Codespaces provides:
- **4 CPUs**
- **8GB RAM**
- **32GB storage**

This is sufficient for individual labs but limits concurrent execution.

## Quick Start

```bash
# Run all labs sequentially (full test suite)
./scripts/test-all-labs.sh

# Run quick subset (skip enterprise-vpn - resource heavy)
./scripts/test-all-labs.sh --quick

# Run specific lab only
./scripts/test-all-labs.sh --lab ospf-basics

# Custom JSON output path
./scripts/test-all-labs.sh --json results/my-report.json
```

## Lab Resource Requirements

| Lab | Containers | Est. Memory | Codespaces Friendly |
|-----|-----------|-------------|---------------------|
| ospf-basics | 3 | ~500MB | Yes |
| bgp-ebgp-basics | 4 | ~600MB | Yes |
| linux-network-namespaces | 4 | ~200MB | Yes |
| vyos-firewall-basics | 3 | ~800MB | Yes |
| enterprise-vpn-migration | 16 | ~4GB | Use `--quick` |
| zero-trust-fundamentals | 3 | ~1GB | Yes |

## Running Individual Labs

### Quick Method (via test runner)
```bash
./scripts/test-all-labs.sh --lab ospf-basics
```

### Manual Method
```bash
# OSPF example
cd ospf-basics
sudo containerlab deploy -t topology.clab.yml
sleep 60  # Wait for convergence
sudo bash scripts/validate.sh
sudo containerlab destroy -t topology.clab.yml

# Zero Trust (docker-compose)
cd zero-trust-fundamentals
docker-compose up -d --build
sleep 30
bash scripts/validate.sh
docker-compose down -v
```

## Test Output

The test runner generates both console output and a JSON report:

### Console Output
```
=========================================
Testing: ospf-basics
=========================================
--- Deploying topology ---
...
--- Running validation tests ---
Test 1: OSPF neighbor state on r1...
  PASSED - ...

>>> ospf-basics PASSED (180s)
```

### JSON Report (`test-results.json`)
```json
{
  "run_id": "2024-12-14T10:30:00Z",
  "environment": "codespaces",
  "total_labs": 6,
  "passed_labs": 6,
  "failed_labs": 0,
  "labs": [
    {
      "name": "ospf-basics",
      "status": "passed",
      "tests_passed": 6,
      "tests_failed": 0,
      "duration_seconds": 180
    }
  ]
}
```

## Tips for Codespaces

1. **Run one lab at a time** - The test runner handles this automatically
2. **Use `--quick` for routine testing** - Skips the resource-heavy enterprise-vpn lab
3. **Monitor resources** - Use `docker stats` to watch memory usage
4. **Cleanup between labs** - The test runner handles cleanup automatically

## Troubleshooting

### Out of Memory
```bash
# Force cleanup all containers
docker rm -f $(docker ps -aq)
docker system prune -f
```

### Lab Won't Start
```bash
# Check for leftover containers
docker ps -a

# Check containerlab state
sudo containerlab inspect --all

# Force cleanup specific lab
cd ospf-basics
sudo containerlab destroy -t topology.clab.yml --cleanup
```

### SSH Connection Issues (FRR Labs)
```bash
# Test SSH access manually
ssh -p 2221 admin@localhost  # Password: cisco

# Check if port is mapped
docker port clab-ospf-basics-r1
```

### Zero Trust Services Not Starting
```bash
# Check container logs
docker logs zt-identity
docker logs zt-web
docker logs zt-mongodb

# Rebuild images
cd zero-trust-fundamentals
docker-compose down -v
docker-compose build --no-cache
docker-compose up -d
```

## CI/CD Integration

The GitHub Actions workflow runs all 6 labs in parallel on every push/PR:

- `validate-ospf` - OSPF Basics
- `validate-bgp` - BGP eBGP Basics
- `validate-netns` - Linux Network Namespaces
- `validate-vyos` - VyOS Firewall Basics
- `validate-enterprise-vpn` - Enterprise VPN Migration
- `validate-zero-trust` - Zero Trust Fundamentals
- `test-summary` - Aggregates all results

View results in the Actions tab of the GitHub repository.
