# Parallel Testing Framework

This directory contains a testing framework for simulating student exercises across all containerlab labs.

## Structure

```
parallel-testing/
├── lib/                          # Shared library functions
│   ├── common.sh                # Common utility functions
│   └── result-collector.sh      # JSON result collection
├── student-tests/               # Student exercise simulations
│   ├── ospf-basics-exercises.sh
│   ├── bgp-ebgp-exercises.sh (planned)
│   ├── linux-namespaces-exercises.sh
│   ├── vyos-firewall-exercises.sh
│   ├── enterprise-vpn-exercises.sh
│   └── zero-trust-exercises.sh
└── results/                     # JSON output files
    └── *.json
```

## Library Functions

### common.sh
- `log_info()` - Blue info messages
- `log_success()` - Green success messages
- `log_warning()` - Yellow warning messages
- `log_error()` - Red error messages
- `exec_vtysh()` - Execute vtysh command in container
- `exec_bash()` - Execute bash command in container
- `check_container()` - Verify container is running
- `count_pattern()` - Count pattern matches in output
- `has_pattern()` - Check if pattern exists in output

### result-collector.sh
- `add_result()` - Add exercise result to collection
- `output_results()` - Generate JSON output
- `save_results()` - Save results to file

## Usage

### Running Student Exercise Tests

```bash
# Make sure lab is deployed first
cd ospf-basics
sudo containerlab deploy -t topology.clab.yml

# Run student exercises
cd ../parallel-testing
./student-tests/ospf-basics-exercises.sh
```

### JSON Output Format

```json
{
  "lab": "ospf-basics",
  "timestamp": "2025-12-15T14:30:00Z",
  "summary": {
    "total": 5,
    "passed": 5,
    "failed": 0
  },
  "exercises": [
    {
      "exercise": 1,
      "name": "Verify OSPF Neighbors",
      "status": "passed",
      "expected": "2 neighbors in Full state",
      "actual": "Found 2 neighbors in Full state",
      "details": "r1 has correct OSPF adjacencies"
    }
  ]
}
```

## Creating New Exercise Scripts

1. Source the library files:
```bash
source "$LIB_DIR/common.sh"
source "$LIB_DIR/result-collector.sh"
```

2. Define exercise functions:
```bash
exercise_1() {
    log_info "Exercise 1: Description"
    
    # Run commands
    output=$(exec_vtysh "$container" "show command")
    
    # Validate results
    if [ condition ]; then
        add_result 1 "Exercise Name" "passed" "$expected" "$actual" "$details"
        log_success "PASSED"
    else
        add_result 1 "Exercise Name" "failed" "$expected" "$actual" "$details"
        log_error "FAILED"
    fi
}
```

3. Output results:
```bash
output_results "$LAB_NAME"
save_results "$LAB_NAME" "$OUTPUT_FILE"
```

## Exercise Pattern

Each student exercise script follows this pattern:

1. **Pre-flight checks** - Verify containers are running
2. **Exercise execution** - Run commands via docker exec
3. **Validation** - Check expected vs actual results
4. **Result collection** - Add to JSON results array
5. **Summary output** - Display and save JSON results

## Benefits

- **Parallel testing** - Can run multiple lab exercises simultaneously
- **Consistent format** - Standardized JSON output
- **Student simulation** - Tests exercises exactly as students would run them
- **CI/CD ready** - Easy integration into GitHub Actions
- **Detailed reporting** - JSON output for analysis and tracking
