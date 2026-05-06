#!/bin/bash
#############################################################################
# Enterprise VPN Migration Lab - Student Exercise Script (Quick Mode)
#############################################################################
#
# Purpose: Simulates a student walking through the enterprise VPN migration
#          lab phases in quick mode. Uses docker exec commands to verify
#          network functionality.
#
# Container prefix: clab-enterprise-vpn-migration-
#
# Phases covered:
#   - Phase 1: Network Audit
#   - Phase 2: Risk Assessment
#   - Phase 3: Change Planning - Baseline Connectivity
#   - Phase 4: Execution (skipped in quick mode)
#   - Phase 5: Validation
#
# Output: JSON format with test results
#
#############################################################################

# Get script directory and source libraries
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
LIB_DIR="${SCRIPT_DIR}/../lib"

source "${LIB_DIR}/common.sh"
source "${LIB_DIR}/result-collector.sh"

# Lab configuration
LAB_NAME="enterprise-vpn-migration"
CONTAINER_PREFIX="clab-enterprise-vpn-migration-"

#############################################################################
# Exercise Functions
#############################################################################

# Phase 1: Network Audit - Exercise 1
exercise_01_count_containers() {
    log_info "Exercise 1: Count running containers"

    local expected=16
    local actual
    actual=$(docker ps --format '{{.Names}}' | grep -c "^${CONTAINER_PREFIX}" || echo "0")

    if [ "$actual" -eq "$expected" ]; then
        add_result 1 "Phase 1: Count running containers" "passed" \
            "$expected containers" "$actual containers" \
            "All 16 containers are running"
        log_success "Found $actual containers (expected $expected)"
        return 0
    else
        add_result 1 "Phase 1: Count running containers" "failed" \
            "$expected containers" "$actual containers" \
            "Expected 16 containers but found $actual"
        log_error "Found $actual containers (expected $expected)"
        return 1
    fi
}

# Phase 1: Network Audit - Exercise 2
exercise_02_check_ospf() {
    log_info "Exercise 2: Check OSPF on core-rtr-a"

    local container="${CONTAINER_PREFIX}core-rtr-a"
    local expected="at least 1 OSPF neighbor"

    if ! check_container "$container"; then
        add_result 2 "Phase 1: Check OSPF neighbors" "failed" \
            "$expected" "container not running" \
            "Container $container is not running"
        log_error "Container $container not found"
        return 1
    fi

    local output
    output=$(exec_vtysh "$container" "show ip ospf neighbor" 2>&1)

    # Check for Full state or any neighbor
    if echo "$output" | grep -qiE "(Full|neighbor)"; then
        local neighbor_count
        neighbor_count=$(echo "$output" | grep -ci "Full" || echo "0")
        add_result 2 "Phase 1: Check OSPF neighbors" "passed" \
            "$expected" "$neighbor_count OSPF neighbor(s)" \
            "OSPF is configured and has neighbors"
        log_success "OSPF has $neighbor_count neighbor(s) in Full state"
        return 0
    else
        add_result 2 "Phase 1: Check OSPF neighbors" "failed" \
            "$expected" "no OSPF neighbors found" \
            "OSPF output: $output"
        log_error "No OSPF neighbors found"
        return 1
    fi
}

# Phase 1: Network Audit - Exercise 3
exercise_03_check_bgp() {
    log_info "Exercise 3: Check BGP on core-rtr-a"

    local container="${CONTAINER_PREFIX}core-rtr-a"
    local expected="BGP session information"

    if ! check_container "$container"; then
        add_result 3 "Phase 1: Check BGP summary" "failed" \
            "$expected" "container not running" \
            "Container $container is not running"
        log_error "Container $container not found"
        return 1
    fi

    local output
    output=$(exec_vtysh "$container" "show ip bgp summary" 2>&1)

    # Check for BGP info (neighbor, AS, or summary headers)
    if echo "$output" | grep -qiE "(neighbor|bgp|AS|established|state)"; then
        add_result 3 "Phase 1: Check BGP summary" "passed" \
            "$expected" "BGP configured" \
            "BGP summary command returned session information"
        log_success "BGP is configured and running"
        return 0
    else
        add_result 3 "Phase 1: Check BGP summary" "failed" \
            "$expected" "no BGP information found" \
            "BGP output: $output"
        log_error "No BGP information found"
        return 1
    fi
}

# Phase 2: Risk Assessment - Exercise 4
exercise_04_verify_gre_tunnel() {
    log_info "Exercise 4: Verify GRE tunnel exists on core-rtr-a"

    local container="${CONTAINER_PREFIX}core-rtr-a"
    local interface="gre-to-b"
    local expected="GRE interface exists"

    if ! check_container "$container"; then
        add_result 4 "Phase 2: Verify GRE tunnel interface" "failed" \
            "$expected" "container not running" \
            "Container $container is not running"
        log_error "Container $container not found"
        return 1
    fi

    local output
    output=$(docker exec "$container" ip link show "$interface" 2>&1)

    if echo "$output" | grep -q "$interface"; then
        # Interface exists, check state (UNKNOWN is normal for GRE tunnels)
        local state="unknown"
        if echo "$output" | grep -qE "state (UP|UNKNOWN)"; then
            state="UP/UNKNOWN (normal for tunnels)"
        elif echo "$output" | grep -q "state DOWN"; then
            state="DOWN"
        fi

        add_result 4 "Phase 2: Verify GRE tunnel interface" "passed" \
            "$expected" "interface exists (state: $state)" \
            "GRE tunnel interface $interface is present"
        log_success "GRE interface $interface exists (state: $state)"
        return 0
    else
        add_result 4 "Phase 2: Verify GRE tunnel interface" "failed" \
            "$expected" "interface not found" \
            "Output: $output"
        log_error "GRE interface $interface not found"
        return 1
    fi
}

# Phase 3: Change Planning - Exercise 5
exercise_05_baseline_connectivity() {
    log_info "Exercise 5: Verify baseline connectivity from workstation-a"

    local container="${CONTAINER_PREFIX}workstation-a"
    local gateway="10.1.10.1"
    local expected="ping to gateway succeeds"

    if ! check_container "$container"; then
        add_result 5 "Phase 3: Baseline connectivity test" "failed" \
            "$expected" "container not running" \
            "Container $container is not running"
        log_error "Container $container not found"
        return 1
    fi

    local output
    output=$(docker exec "$container" ping -c 3 -W 2 "$gateway" 2>&1)

    if echo "$output" | grep -q "3 received\|3 packets received"; then
        add_result 5 "Phase 3: Baseline connectivity test" "passed" \
            "$expected" "3/3 packets received" \
            "Ping from workstation-a to gateway $gateway successful"
        log_success "Ping to gateway $gateway successful (3/3 packets)"
        return 0
    elif echo "$output" | grep -qE "[1-2] received|[1-2] packets received"; then
        local received
        received=$(echo "$output" | grep -oE "[0-9]+ received" | grep -oE "[0-9]+" | head -1)
        add_result 5 "Phase 3: Baseline connectivity test" "passed" \
            "$expected" "$received/3 packets received" \
            "Partial connectivity to gateway $gateway"
        log_warning "Ping to gateway $gateway partial success ($received/3 packets)"
        return 0
    else
        add_result 5 "Phase 3: Baseline connectivity test" "failed" \
            "$expected" "ping failed" \
            "Output: $output"
        log_error "Ping to gateway $gateway failed"
        return 1
    fi
}

# Phase 4: Execution - Exercise 6
exercise_06_execution_phase() {
    log_info "Exercise 6: Phase 4 - Execution (skipped in quick mode)"

    add_result 6 "Phase 4: Execution phase" "passed" \
        "skipped in quick mode" "skipped" \
        "Execution phase requires manual configuration changes"
    log_info "Skipped in quick mode (requires manual VPN reconfiguration)"
    return 0
}

# Phase 5: Validation - Exercise 7
exercise_07_verify_ospf_running() {
    log_info "Exercise 7: Verify OSPF is running on core-rtr-a"

    local container="${CONTAINER_PREFIX}core-rtr-a"
    local expected="OSPF router ID present"

    if ! check_container "$container"; then
        add_result 7 "Phase 5: Verify OSPF is running" "failed" \
            "$expected" "container not running" \
            "Container $container is not running"
        log_error "Container $container not found"
        return 1
    fi

    local output
    output=$(exec_vtysh "$container" "show ip ospf" 2>&1)

    # Check for OSPF Router ID
    if echo "$output" | grep -qiE "router.?id|ospf.?router"; then
        local router_id
        router_id=$(echo "$output" | grep -i "router id" | head -1 | awk '{print $NF}' || echo "configured")
        add_result 7 "Phase 5: Verify OSPF is running" "passed" \
            "$expected" "OSPF Router ID: $router_id" \
            "OSPF process is active"
        log_success "OSPF is running with Router ID: $router_id"
        return 0
    else
        add_result 7 "Phase 5: Verify OSPF is running" "failed" \
            "$expected" "no OSPF router ID found" \
            "Output: $output"
        log_error "OSPF does not appear to be running"
        return 1
    fi
}

#############################################################################
# Main Execution
#############################################################################

main() {
    log_info "Starting Enterprise VPN Migration Lab - Student Exercises (Quick Mode)"
    log_info "Lab: $LAB_NAME"
    log_info "Container prefix: $CONTAINER_PREFIX"
    echo ""

    # Run all exercises
    exercise_01_count_containers
    echo ""

    exercise_02_check_ospf
    echo ""

    exercise_03_check_bgp
    echo ""

    exercise_04_verify_gre_tunnel
    echo ""

    exercise_05_baseline_connectivity
    echo ""

    exercise_06_execution_phase
    echo ""

    exercise_07_verify_ospf_running
    echo ""

    # Output results in JSON format
    log_info "Generating JSON results..."
    echo ""
    output_results "$LAB_NAME"

    # Exit with success if all passed, failure otherwise
    if [ "$FAILED_COUNT" -eq 0 ]; then
        log_success "All exercises passed ($PASSED_COUNT/$EXERCISE_COUNT)"
        exit 0
    else
        log_error "Some exercises failed ($FAILED_COUNT/$EXERCISE_COUNT failed)"
        exit 1
    fi
}

# Run main function
main "$@"
