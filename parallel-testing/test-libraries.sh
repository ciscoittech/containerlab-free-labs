#!/bin/bash

# Test script for parallel-testing libraries
# Tests common.sh and result-collector.sh functionality

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Source libraries
source "${SCRIPT_DIR}/lib/common.sh"
source "${SCRIPT_DIR}/lib/result-collector.sh"

echo "========================================="
echo "Testing Parallel Testing Libraries"
echo "========================================="
echo ""

# Test 1: Logging functions
echo "Test 1: Logging Functions"
log_info "This is an info message"
log_success "This is a success message"
log_warn "This is a warning message"
log_error "This is an error message"
echo ""

# Test 2: Timestamp functions
echo "Test 2: Timestamp Functions"
TIMESTAMP=$(get_timestamp)
FILE_TIMESTAMP=$(get_file_timestamp)
log_info "ISO timestamp: $TIMESTAMP"
log_info "File timestamp: $FILE_TIMESTAMP"
echo ""

# Test 3: Container name generation
echo "Test 3: Container Name Generation"
CONTAINER=$(get_container_name "ospf-basics" "r1")
log_info "Container name: $CONTAINER"
echo ""

# Test 4: Initialize results
echo "Test 4: Initialize Results"
init_results "${SCRIPT_DIR}/test-results"
log_info "Results dir: $RESULTS_DIR"
echo ""

# Test 5: Lab result collection
echo "Test 5: Lab Result Collection"
start_lab_results "test-lab"

# Add some test results
pass_test "connectivity-test" "Ping succeeded"
pass_test "ospf-neighbor-test" "OSPF neighbor is Full"
fail_test "bgp-test" "BGP session not established" "Connection refused on port 179"
skip_test "optional-test" "Feature not enabled in this lab"

finalize_lab_results
echo ""

# Test 6: Generate summary
echo "Test 6: Generate Summary"
generate_summary
echo ""

# Test 7: Verify files created
echo "Test 7: Verify Output Files"
if [ -f "${RESULTS_DIR}/test-lab.json" ]; then
    log_success "Lab result file created"
    echo "Contents:"
    cat "${RESULTS_DIR}/test-lab.json" | head -20
else
    log_error "Lab result file not found"
fi
echo ""

if [ -f "${RESULTS_DIR}/summary.json" ]; then
    log_success "Summary file created"
    echo "Contents:"
    cat "${RESULTS_DIR}/summary.json"
else
    log_error "Summary file not found"
fi
echo ""

# Test 8: Config file parsing (requires Python with PyYAML)
echo "Test 8: Config File Parsing"
if command -v python3 &> /dev/null; then
    if python3 -c "import yaml" 2>/dev/null; then
        WAIT_TIME=$(get_config_value "${SCRIPT_DIR}/config.yml" "labs.ospf-basics.wait_time")
        if [ -n "$WAIT_TIME" ]; then
            log_success "Config parsing works: ospf-basics wait_time = $WAIT_TIME"
        else
            log_warn "Config parsing returned empty value"
        fi
    else
        log_warn "PyYAML not installed, skipping config parsing test"
    fi
else
    log_warn "Python3 not available, skipping config parsing test"
fi
echo ""

log_success "Library tests completed!"
echo ""
echo "Test results saved to: $RESULTS_DIR"
echo ""
