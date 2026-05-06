# Architecture - OSPF Basics Student Exercise Script

## Script Flow Diagram

```
┌─────────────────────────────────────────────────────────────┐
│                ospf-basics-exercises.sh                     │
└─────────────────────────────────────────────────────────────┘
                            │
                            ▼
        ┌───────────────────────────────────────┐
        │  Source Library Files                  │
        │  • lib/common.sh                       │
        │  • lib/result-collector.sh             │
        └───────────────────────────────────────┘
                            │
                            ▼
        ┌───────────────────────────────────────┐
        │  Pre-flight Checks                     │
        │  • Verify r1 container running         │
        │  • Verify r2 container running         │
        │  • Verify r3 container running         │
        └───────────────────────────────────────┘
                            │
                            ▼
    ┌──────────────────────────────────────────────┐
    │              Exercise 1                       │
    │  Verify OSPF Neighbors on r1                 │
    ├──────────────────────────────────────────────┤
    │  1. exec_vtysh(r1, "show ip ospf neighbor")  │
    │  2. count_pattern(output, "Full")            │
    │  3. Validate: count == 2                     │
    │  4. add_result(1, status, expected, actual)  │
    └──────────────────────────────────────────────┘
                            │
                            ▼
    ┌──────────────────────────────────────────────┐
    │              Exercise 2                       │
    │  View OSPF Routes on r1                      │
    ├──────────────────────────────────────────────┤
    │  1. exec_vtysh(r1, "show ip route ospf")     │
    │  2. has_pattern(output, "10.0.2.0/24")       │
    │  3. has_pattern(output, "10.0.3.0/24")       │
    │  4. has_pattern(output, "192.168.100.1/32")  │
    │  5. Validate: all 3 routes found             │
    │  6. add_result(2, status, expected, actual)  │
    └──────────────────────────────────────────────┘
                            │
                            ▼
    ┌──────────────────────────────────────────────┐
    │              Exercise 3                       │
    │  View OSPF Database on r2                    │
    ├──────────────────────────────────────────────┤
    │  1. exec_vtysh(r2, "show ip ospf database")  │
    │  2. has_pattern(output, "1.1.1.1")           │
    │  3. has_pattern(output, "2.2.2.2")           │
    │  4. has_pattern(output, "3.3.3.3")           │
    │  5. Validate: 3 Router LSAs found            │
    │  6. add_result(3, status, expected, actual)  │
    └──────────────────────────────────────────────┘
                            │
                            ▼
    ┌──────────────────────────────────────────────┐
    │              Exercise 4                       │
    │  Test Connectivity from r1                   │
    ├──────────────────────────────────────────────┤
    │  1. docker exec r1 ping 192.168.100.1        │
    │  2. Validate: ping succeeds                  │
    │  3. add_result(4, status, expected, actual)  │
    └──────────────────────────────────────────────┘
                            │
                            ▼
    ┌──────────────────────────────────────────────┐
    │              Exercise 5                       │
    │  Verify OSPF Interface on r2                 │
    ├──────────────────────────────────────────────┤
    │  1. exec_vtysh(r2, "show ip ospf int eth1")  │
    │  2. has_pattern(output, "OSPF enabled")      │
    │  3. has_pattern(output, "Area.*0.0.0.0")     │
    │  4. Validate: both patterns found            │
    │  5. add_result(5, status, expected, actual)  │
    └──────────────────────────────────────────────┘
                            │
                            ▼
        ┌───────────────────────────────────────┐
        │  Generate Results                      │
        │  • output_results("ospf-basics")       │
        │  • save_results(lab, output_file)      │
        │  • Display JSON to stdout              │
        └───────────────────────────────────────┘
                            │
                            ▼
        ┌───────────────────────────────────────┐
        │  Exit with Status                      │
        │  • 0 if FAILED_COUNT == 0              │
        │  • 1 if FAILED_COUNT > 0               │
        └───────────────────────────────────────┘
```

## Component Interactions

```
┌────────────────────┐
│  Exercise Script   │
│  (ospf-basics)     │
└─────────┬──────────┘
          │
          ├─────────────────┐
          │                 │
          ▼                 ▼
┌─────────────────┐   ┌────────────────────┐
│   common.sh     │   │ result-collector.sh│
│                 │   │                    │
│ • log_*()       │   │ • add_result()     │
│ • exec_vtysh()  │   │ • output_results() │
│ • check_*()     │   │ • save_results()   │
│ • has_pattern() │   │                    │
└─────────┬───────┘   └────────┬───────────┘
          │                    │
          └──────────┬─────────┘
                     │
                     ▼
          ┌──────────────────────┐
          │  Docker Containers   │
          │                      │
          │  • clab-ospf-r1      │
          │  • clab-ospf-r2      │
          │  • clab-ospf-r3      │
          └──────────────────────┘
```

## Data Flow

```
Input:
  └─> Deployed lab containers

Processing:
  ├─> Check container health
  ├─> Execute vtysh commands
  ├─> Parse output with regex
  ├─> Validate against expectations
  └─> Collect results in array

Output:
  ├─> Console (colored, human-readable)
  ├─> JSON file (machine-readable)
  └─> Exit code (0=pass, 1=fail)
```

## Library Functions

### common.sh Functions

| Function | Purpose | Example |
|----------|---------|---------|
| `log_info()` | Blue info message | `log_info "Starting test"` |
| `log_success()` | Green success message | `log_success "Test passed"` |
| `log_error()` | Red error message | `log_error "Test failed"` |
| `exec_vtysh()` | Run vtysh command | `exec_vtysh "r1" "show ip route"` |
| `check_container()` | Verify running | `check_container "clab-ospf-r1"` |
| `count_pattern()` | Count matches | `count_pattern "$out" "Full"` |
| `has_pattern()` | Check exists | `has_pattern "$out" "OSPF"` |

### result-collector.sh Functions

| Function | Purpose | Example |
|----------|---------|---------|
| `add_result()` | Add test result | `add_result 1 "Test" "passed" "2" "2" "OK"` |
| `output_results()` | Print JSON | `output_results "ospf-basics"` |
| `save_results()` | Save to file | `save_results "lab" "out.json"` |

## JSON Result Schema

```json
{
  "lab": "string",              // Lab name
  "timestamp": "ISO8601",       // When test ran
  "summary": {
    "total": 5,                 // Total exercises
    "passed": 5,                // Passed count
    "failed": 0                 // Failed count
  },
  "exercises": [
    {
      "exercise": 1,            // Exercise number
      "name": "string",         // Exercise name
      "status": "passed|failed",// Pass/fail status
      "expected": "string",     // What we expected
      "actual": "string",       // What we got
      "details": "string"       // Additional context
    }
  ]
}
```

## Error Handling

```
Container Check Failed
  └─> Log error
  └─> Add failed result
  └─> Continue to next exercise

Command Execution Failed
  └─> Log error
  └─> Add failed result with error details
  └─> Continue to next exercise

Validation Failed
  └─> Log error
  └─> Add failed result with expected vs actual
  └─> Continue to next exercise

All Exercises Complete
  └─> Generate summary
  └─> Output JSON
  └─> Exit with appropriate code
```

## Performance Characteristics

| Metric | Value |
|--------|-------|
| Total runtime | ~10-15 seconds |
| Docker exec calls | ~8 calls |
| Network operations | 1 ping test |
| Memory usage | Minimal (<10MB) |
| Disk writes | 1 JSON file (~2KB) |

## Extensibility

The framework is designed to be extended:

1. **New exercises**: Add `exercise_N()` function
2. **New labs**: Copy script, update container prefix and exercises
3. **New validations**: Use library functions or add new ones
4. **Custom output**: Modify `output_results()` function
5. **Parallel execution**: Run multiple scripts simultaneously

## Security Considerations

- ✅ No credentials stored in scripts
- ✅ Read-only operations (show commands only)
- ✅ No configuration changes to lab
- ✅ JSON output sanitized (quotes escaped)
- ✅ No shell injection vulnerabilities
