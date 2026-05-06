# Parallel Testing Library

Shared utility functions for containerlab lab testing and result collection.

## Files

### common.sh (227 lines)
Common utility functions for container management, logging, and configuration.

**Color Codes:**
- `RED`, `GREEN`, `YELLOW`, `BLUE`, `NC` - ANSI color codes for terminal output

**Logging Functions:**
- `log_info(message)` - Blue info message
- `log_success(message)` - Green success message
- `log_error(message)` - Red error message
- `log_warn(message)` - Yellow warning message

**Container Functions:**
- `check_container_running(container_name)` - Check if container is running
- `run_docker_cmd(container_name, command)` - Execute command in container
- `get_container_name(lab_name, node_name)` - Generate containerlab container name
- `verify_lab_containers(lab_name, containers...)` - Verify all lab containers are running

**Wait Functions:**
- `wait_for_convergence(lab_name, seconds)` - Wait for protocol convergence with progress bar

**Config Functions:**
- `get_config_value(yaml_file, key_path)` - Parse YAML config values (requires Python + PyYAML)

**Time Functions:**
- `get_timestamp()` - ISO 8601 timestamp for JSON
- `get_file_timestamp()` - Filename-safe timestamp
- `calculate_duration(start_time, end_time)` - Calculate duration in seconds

### result-collector.sh (342 lines)
JSON result collection and reporting for test runs.

**Initialization:**
- `init_results([output_dir])` - Create results directory with timestamp (default: `results/`)

**Lab Result Collection:**
- `start_lab_results(lab_name)` - Begin collecting results for a lab
- `add_exercise_result(name, status, message, [details])` - Add test result
  - `status`: "passed", "failed", or "skipped"
- `finalize_lab_results()` - Write lab JSON file and reset state

**Summary Generation:**
- `generate_summary()` - Aggregate all lab results into summary.json

**Helper Functions:**
- `pass_test(name, [message])` - Quick pass result
- `fail_test(name, [message], [details])` - Quick fail result
- `skip_test(name, [message])` - Quick skip result

## Usage Example

```bash
#!/bin/bash

# Source the libraries
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/../lib/common.sh"
source "${SCRIPT_DIR}/../lib/result-collector.sh"

# Initialize results
init_results "./results"

# Start lab testing
start_lab_results "ospf-basics"

# Wait for convergence
wait_for_convergence "ospf-basics" 60

# Run tests
CONTAINER=$(get_container_name "ospf-basics" "r1")
OUTPUT=$(run_docker_cmd "$CONTAINER" "vtysh -c 'show ip ospf neighbor'")

if echo "$OUTPUT" | grep -q "Full"; then
    pass_test "OSPF Neighbors" "All neighbors in Full state"
else
    fail_test "OSPF Neighbors" "Neighbors not in Full state" "$OUTPUT"
fi

# Finalize results
finalize_lab_results

# Generate summary
generate_summary
```

## Output Format

### Lab Result File: `results/run-TIMESTAMP/ospf-basics.json`
```json
{
  "lab_name": "ospf-basics",
  "start_time": "2025-12-15T14:00:00Z",
  "end_time": "2025-12-15T14:02:30Z",
  "duration_seconds": 150,
  "overall_status": "passed",
  "summary": {
    "total": 5,
    "passed": 4,
    "failed": 1,
    "skipped": 0
  },
  "exercises": [
    {
      "exercise": "OSPF Neighbors",
      "status": "passed",
      "message": "All neighbors in Full state",
      "details": "",
      "timestamp": "2025-12-15T14:01:00Z"
    }
  ]
}
```

### Summary File: `results/run-TIMESTAMP/summary.json`
```json
{
  "test_run_summary": {
    "start_time": "2025-12-15T14:00:00Z",
    "end_time": "2025-12-15T14:10:00Z",
    "duration_seconds": 600,
    "overall_status": "passed"
  },
  "lab_summary": {
    "total_labs": 3,
    "passed_labs": 2,
    "failed_labs": 1
  },
  "exercise_summary": {
    "total_exercises": 15,
    "passed_exercises": 12,
    "failed_exercises": 2,
    "skipped_exercises": 1
  },
  "labs": [
    {
      "lab_name": "ospf-basics",
      "status": "passed",
      "total": 5,
      "passed": 5,
      "failed": 0,
      "skipped": 0
    }
  ]
}
```

## Dependencies

- **bash** (tested with 3.2+)
- **docker** - For container operations
- **python3 + PyYAML** - For YAML config parsing (optional)
- Standard Unix tools: `date`, `grep`, `sed`

## macOS Note

The `calculate_duration()` function uses `date -j` which is macOS-specific. For Linux, modify to use GNU date format parsing.
