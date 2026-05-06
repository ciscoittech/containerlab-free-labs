# Parallel Testing Framework - Documentation Index

## Quick Links

| Document | Purpose |
|----------|---------|
| [QUICKSTART.md](QUICKSTART.md) | Get started in 1 minute |
| [USAGE.md](USAGE.md) | Detailed usage instructions |
| [README.md](README.md) | Framework overview |
| [ARCHITECTURE.md](ARCHITECTURE.md) | Technical architecture |
| [CREATED.md](CREATED.md) | What was built |

## File Structure

```
parallel-testing/
├── INDEX.md                     # This file
├── QUICKSTART.md               # 1-minute quick start
├── USAGE.md                    # Detailed usage guide
├── README.md                   # Framework overview
├── ARCHITECTURE.md             # Technical details
├── CREATED.md                  # Build summary
│
├── lib/                        # Shared libraries
│   ├── common.sh               # Utility functions
│   └── result-collector.sh     # JSON output
│
├── student-tests/              # Exercise scripts
│   ├── ospf-basics-exercises.sh        # ✅ Complete
│   ├── bgp-ebgp-basics-exercises.sh    # Planned
│   ├── linux-namespaces-exercises.sh   # Planned
│   ├── vyos-firewall-exercises.sh      # Planned
│   ├── enterprise-vpn-exercises.sh     # Planned
│   └── zero-trust-exercises.sh         # Planned
│
└── results/                    # Output files
    ├── example-output.json     # Example
    └── *.json                  # Generated results
```

## For First-Time Users

1. **Quick Start**: Read [QUICKSTART.md](QUICKSTART.md)
2. **Run Script**: `./student-tests/ospf-basics-exercises.sh`
3. **Check Results**: `cat results/ospf-basics-student-results.json`

## For Developers

1. **Architecture**: Read [ARCHITECTURE.md](ARCHITECTURE.md)
2. **Library Docs**: Read [README.md](README.md)
3. **Create Script**: Use template from existing scripts

## For CI/CD Integration

1. **Usage Guide**: Read [USAGE.md](USAGE.md) CI/CD section
2. **Exit Codes**: 0 = pass, 1 = fail
3. **JSON Output**: Parse `results/*.json` files

## Script Capabilities

### OSPF Basics Exercises (Complete)

| Exercise | Validation |
|----------|------------|
| 1. Verify OSPF Neighbors | 2 neighbors in Full state |
| 2. View OSPF Routes | 3 routes learned |
| 3. View OSPF Database | 3 Router LSAs present |
| 4. Test Connectivity | Ping succeeds to r3 loopback |
| 5. Verify OSPF Interface | OSPF enabled on eth1 |

### Future Labs (Planned)

- BGP eBGP Basics
- Linux Network Namespaces  
- VyOS Firewall Basics
- Enterprise VPN Migration
- Zero Trust Fundamentals

## Library Functions

### From common.sh
- `log_info()`, `log_success()`, `log_error()`
- `exec_vtysh()`, `exec_bash()`
- `check_container()`
- `count_pattern()`, `has_pattern()`

### From result-collector.sh
- `add_result()`
- `output_results()`
- `save_results()`

## Output Format

### Console Output
- Colored messages (blue=info, green=success, red=error)
- Exercise-by-exercise progress
- Summary at end

### JSON Output
```json
{
  "lab": "ospf-basics",
  "timestamp": "2025-12-15T14:30:00Z",
  "summary": {"total": 5, "passed": 5, "failed": 0},
  "exercises": [...]
}
```

## Troubleshooting

| Issue | Solution |
|-------|----------|
| Container not found | Deploy lab first |
| Exercises failing | Wait for OSPF convergence |
| Permission denied | Make script executable |
| Library not found | Run from correct directory |

## Contributing

To add a new lab exercise script:

1. Copy `ospf-basics-exercises.sh` as template
2. Update container prefix and lab name
3. Modify exercise functions for new lab
4. Update expected values for new topology
5. Test with deployed lab
6. Update this INDEX.md

## Support

See individual documentation files for:
- Quick start: [QUICKSTART.md](QUICKSTART.md)
- Usage help: [USAGE.md](USAGE.md)
- Architecture: [ARCHITECTURE.md](ARCHITECTURE.md)
- Build info: [CREATED.md](CREATED.md)
