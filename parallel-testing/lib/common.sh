#!/bin/bash

# Color codes for output
export RED='\033[0;31m'
export GREEN='\033[0;32m'
export YELLOW='\033[1;33m'
export BLUE='\033[0;34m'
export NC='\033[0m' # No Color

# Logging functions
log_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

log_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

log_warn() {
    echo -e "${YELLOW}[WARN]${NC} $1"
}

# Check if a container is running
# Usage: check_container_running <container_name>
# Returns: 0 if running, 1 if not
check_container_running() {
    local container_name="$1"

    if [ -z "$container_name" ]; then
        log_error "Container name not provided to check_container_running"
        return 1
    fi

    if docker ps --format '{{.Names}}' | grep -q "^${container_name}$"; then
        return 0
    else
        log_error "Container ${container_name} is not running"
        return 1
    fi
}

# Wait for protocol convergence
# Usage: wait_for_convergence <lab_name> <seconds>
wait_for_convergence() {
    local lab_name="$1"
    local wait_seconds="$2"

    if [ -z "$lab_name" ] || [ -z "$wait_seconds" ]; then
        log_error "Lab name and wait seconds required for wait_for_convergence"
        return 1
    fi

    log_info "Waiting ${wait_seconds}s for ${lab_name} protocol convergence..."

    local elapsed=0
    local step=5

    while [ $elapsed -lt $wait_seconds ]; do
        sleep $step
        elapsed=$((elapsed + step))
        local remaining=$((wait_seconds - elapsed))

        if [ $remaining -gt 0 ]; then
            echo -ne "\r${BLUE}[INFO]${NC} Progress: ${elapsed}/${wait_seconds}s (${remaining}s remaining)   "
        fi
    done

    echo -ne "\r${GREEN}[SUCCESS]${NC} Convergence wait completed (${wait_seconds}s)                    \n"
    return 0
}

# Execute command in container using docker exec
# Usage: run_docker_cmd <container_name> <command>
# Returns: Command output via stdout, exit code via return
run_docker_cmd() {
    local container_name="$1"
    shift
    local cmd="$@"

    if [ -z "$container_name" ]; then
        log_error "Container name not provided to run_docker_cmd"
        return 1
    fi

    if [ -z "$cmd" ]; then
        log_error "Command not provided to run_docker_cmd"
        return 1
    fi

    # Check if container is running first
    if ! check_container_running "$container_name"; then
        return 1
    fi

    # Execute command and capture both output and exit code
    local output
    local exit_code

    output=$(docker exec "$container_name" sh -c "$cmd" 2>&1)
    exit_code=$?

    # Print output
    echo "$output"

    return $exit_code
}

# Get container name for a lab and node
# Usage: get_container_name <lab_name> <node_name>
get_container_name() {
    local lab_name="$1"
    local node_name="$2"

    if [ -z "$lab_name" ] || [ -z "$node_name" ]; then
        log_error "Lab name and node name required for get_container_name"
        return 1
    fi

    echo "clab-${lab_name}-${node_name}"
}

# Verify all containers for a lab are running
# Usage: verify_lab_containers <lab_name> <container1> [container2] [...]
verify_lab_containers() {
    local lab_name="$1"
    shift
    local containers=("$@")

    if [ -z "$lab_name" ]; then
        log_error "Lab name required for verify_lab_containers"
        return 1
    fi

    if [ ${#containers[@]} -eq 0 ]; then
        log_error "No containers provided for verify_lab_containers"
        return 1
    fi

    local all_running=true

    for node in "${containers[@]}"; do
        local container_name=$(get_container_name "$lab_name" "$node")
        if ! check_container_running "$container_name"; then
            all_running=false
        fi
    done

    if [ "$all_running" = true ]; then
        log_success "All containers verified for ${lab_name}"
        return 0
    else
        log_error "Some containers missing for ${lab_name}"
        return 1
    fi
}

# Parse YAML config (simple implementation for our needs)
# Usage: get_config_value <yaml_file> <key_path>
# Example: get_config_value config.yml "labs.ospf-basics.wait_time"
get_config_value() {
    local yaml_file="$1"
    local key_path="$2"

    if [ ! -f "$yaml_file" ]; then
        log_error "Config file not found: $yaml_file"
        return 1
    fi

    # Simple YAML parsing for our specific structure
    # This handles: labs.<lab_name>.wait_time and similar patterns
    local result
    result=$(python3 -c "
import yaml
import sys

try:
    with open('$yaml_file', 'r') as f:
        data = yaml.safe_load(f)

    keys = '$key_path'.split('.')
    value = data
    for key in keys:
        value = value[key]

    print(value)
except Exception as e:
    sys.exit(1)
" 2>/dev/null)

    if [ $? -eq 0 ]; then
        echo "$result"
        return 0
    else
        return 1
    fi
}

# Get timestamp in ISO 8601 format
get_timestamp() {
    date -u +"%Y-%m-%dT%H:%M:%SZ"
}

# Get timestamp for filenames (no special characters)
get_file_timestamp() {
    date +"%Y%m%d-%H%M%S"
}

# Calculate duration between two timestamps
# Usage: calculate_duration <start_time> <end_time>
calculate_duration() {
    local start_time="$1"
    local end_time="$2"

    local start_epoch=$(date -j -f "%Y-%m-%dT%H:%M:%SZ" "$start_time" +%s 2>/dev/null)
    local end_epoch=$(date -j -f "%Y-%m-%dT%H:%M:%SZ" "$end_time" +%s 2>/dev/null)

    if [ -z "$start_epoch" ] || [ -z "$end_epoch" ]; then
        echo "0"
        return 1
    fi

    echo $((end_epoch - start_epoch))
}

# Alias for backward compatibility
check_container() {
    check_container_running "$@"
}
