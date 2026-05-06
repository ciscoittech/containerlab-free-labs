#!/bin/bash

#############################################################################
# OSPF Basics Lab - Student Exercise Simulation
#
# This script simulates a student walking through the OSPF basics lab
# exercises and validates their work. It uses docker exec commands to
# interact with the lab containers.
#
# Container prefix: clab-ospf-basics-
# Routers: r1, r2, r3
#############################################################################

# Get script directory and source libraries
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
LIB_DIR="$(dirname "$SCRIPT_DIR")/lib"

# Source library files
source "$LIB_DIR/common.sh"
source "$LIB_DIR/result-collector.sh"

# Lab configuration
LAB_NAME="ospf-basics"
CONTAINER_PREFIX="clab-ospf-basics-"

# Output file
RESULTS_DIR="$(dirname "$SCRIPT_DIR")/results"
mkdir -p "$RESULTS_DIR"
OUTPUT_FILE="$RESULTS_DIR/ospf-basics-student-results.json"

#############################################################################
# Exercise Functions
#############################################################################

# Exercise 1: Verify OSPF Neighbors
exercise_1() {
    log_info "Exercise 1: Verify OSPF Neighbors on r1"
    
    local container="${CONTAINER_PREFIX}r1"
    local expected="2 neighbors in Full state"
    
    if ! check_container "$container"; then
        add_result 1 "Verify OSPF Neighbors" "failed" "$expected" "Container not running" "Container $container is not running"
        log_error "Container $container is not running"
        return 1
    fi
    
    # Run the command
    local output
    output=$(exec_vtysh "$container" "show ip ospf neighbor")
    
    # Count Full state neighbors
    local full_count
    full_count=$(count_pattern "$output" "Full")
    
    local actual="Found $full_count neighbors in Full state"
    
    if [ "$full_count" -eq 2 ]; then
        add_result 1 "Verify OSPF Neighbors" "passed" "$expected" "$actual" "r1 has correct OSPF adjacencies"
        log_success "Exercise 1 PASSED: $actual"
        return 0
    else
        add_result 1 "Verify OSPF Neighbors" "failed" "$expected" "$actual" "r1 should have exactly 2 neighbors in Full state"
        log_error "Exercise 1 FAILED: Expected 2 neighbors, found $full_count"
        return 1
    fi
}

# Exercise 2: View OSPF Routes
exercise_2() {
    log_info "Exercise 2: View OSPF Routes on r1"
    
    local container="${CONTAINER_PREFIX}r1"
    local expected_routes=("10.0.2.0/24" "10.0.3.0/24" "192.168.100.1/32")
    local expected="Routes to 10.0.2.0/24, 10.0.3.0/24, 192.168.100.1/32"
    
    if ! check_container "$container"; then
        add_result 2 "View OSPF Routes" "failed" "$expected" "Container not running" "Container $container is not running"
        log_error "Container $container is not running"
        return 1
    fi
    
    # Run the command
    local output
    output=$(exec_vtysh "$container" "show ip route ospf")
    
    # Check for each expected route
    local found_routes=()
    local missing_routes=()
    
    for route in "${expected_routes[@]}"; do
        if has_pattern "$output" "$route"; then
            found_routes+=("$route")
        else
            missing_routes+=("$route")
        fi
    done
    
    local found_count=${#found_routes[@]}
    local expected_count=${#expected_routes[@]}
    
    local actual="Found $found_count of $expected_count expected routes: ${found_routes[*]}"
    
    if [ "$found_count" -eq "$expected_count" ]; then
        add_result 2 "View OSPF Routes" "passed" "$expected" "$actual" "All expected OSPF routes are present"
        log_success "Exercise 2 PASSED: All routes found"
        return 0
    else
        local details="Missing routes: ${missing_routes[*]}"
        add_result 2 "View OSPF Routes" "failed" "$expected" "$actual" "$details"
        log_error "Exercise 2 FAILED: Missing routes: ${missing_routes[*]}"
        return 1
    fi
}

# Exercise 3: View OSPF Database
exercise_3() {
    log_info "Exercise 3: View OSPF Database on r2"
    
    local container="${CONTAINER_PREFIX}r2"
    local expected="3 Router LSAs (one per router)"
    
    if ! check_container "$container"; then
        add_result 3 "View OSPF Database" "failed" "$expected" "Container not running" "Container $container is not running"
        log_error "Container $container is not running"
        return 1
    fi
    
    # Run the command
    local output
    output=$(exec_vtysh "$container" "show ip ospf database")
    
    # Count Router LSAs - look for router IDs (1.1.1.1, 2.2.2.2, 3.3.3.3)
    local lsa_count=0
    
    if has_pattern "$output" "1.1.1.1"; then
        ((lsa_count++))
    fi
    if has_pattern "$output" "2.2.2.2"; then
        ((lsa_count++))
    fi
    if has_pattern "$output" "3.3.3.3"; then
        ((lsa_count++))
    fi
    
    local actual="Found $lsa_count Router LSAs"
    
    if [ "$lsa_count" -eq 3 ]; then
        add_result 3 "View OSPF Database" "passed" "$expected" "$actual" "OSPF database has all router LSAs"
        log_success "Exercise 3 PASSED: Found 3 Router LSAs"
        return 0
    else
        add_result 3 "View OSPF Database" "failed" "$expected" "$actual" "Expected 3 Router LSAs, found $lsa_count"
        log_error "Exercise 3 FAILED: Expected 3 LSAs, found $lsa_count"
        return 1
    fi
}

# Exercise 4: Test Connectivity
exercise_4() {
    log_info "Exercise 4: Test Connectivity from r1 to r3's loopback"
    
    local container="${CONTAINER_PREFIX}r1"
    local target_ip="192.168.100.1"
    local expected="Ping to $target_ip succeeds"
    
    if ! check_container "$container"; then
        add_result 4 "Test Connectivity" "failed" "$expected" "Container not running" "Container $container is not running"
        log_error "Container $container is not running"
        return 1
    fi
    
    # Run ping test
    if docker exec "$container" ping -c 2 -W 2 "$target_ip" >/dev/null 2>&1; then
        local actual="Ping to $target_ip successful"
        add_result 4 "Test Connectivity" "passed" "$expected" "$actual" "End-to-end connectivity verified"
        log_success "Exercise 4 PASSED: Ping successful"
        return 0
    else
        local actual="Ping to $target_ip failed"
        add_result 4 "Test Connectivity" "failed" "$expected" "$actual" "No connectivity to r3 loopback"
        log_error "Exercise 4 FAILED: Ping failed"
        return 1
    fi
}

# Exercise 5: Verify OSPF Interface
exercise_5() {
    log_info "Exercise 5: Verify OSPF is enabled on r2 eth1"
    
    local container="${CONTAINER_PREFIX}r2"
    local interface="eth1"
    local expected="OSPF enabled on $interface with area 0.0.0.0"
    
    if ! check_container "$container"; then
        add_result 5 "Verify OSPF Interface" "failed" "$expected" "Container not running" "Container $container is not running"
        log_error "Container $container is not running"
        return 1
    fi
    
    # Run the command
    local output
    output=$(exec_vtysh "$container" "show ip ospf interface $interface")
    
    # Check for OSPF enabled and area 0
    local has_ospf=false
    local has_area=false
    
    if has_pattern "$output" "OSPF enabled"; then
        has_ospf=true
    fi
    
    if has_pattern "$output" "Area.*0.0.0.0" || has_pattern "$output" "Area 0"; then
        has_area=true
    fi
    
    if [ "$has_ospf" = true ] && [ "$has_area" = true ]; then
        local actual="OSPF is enabled on $interface in area 0.0.0.0"
        add_result 5 "Verify OSPF Interface" "passed" "$expected" "$actual" "Interface correctly configured for OSPF"
        log_success "Exercise 5 PASSED: OSPF enabled on $interface"
        return 0
    else
        local actual="OSPF configuration issue on $interface"
        local details="OSPF enabled: $has_ospf, Area 0 configured: $has_area"
        add_result 5 "Verify OSPF Interface" "failed" "$expected" "$actual" "$details"
        log_error "Exercise 5 FAILED: $details"
        return 1
    fi
}

#############################################################################
# Main Execution
#############################################################################

main() {
    echo "========================================="
    echo "OSPF Basics - Student Exercise Simulation"
    echo "========================================="
    echo ""
    
    # Verify lab is running
    log_info "Checking if lab containers are running..."
    local all_running=true
    
    for router in r1 r2 r3; do
        if ! check_container "${CONTAINER_PREFIX}${router}"; then
            log_error "Container ${CONTAINER_PREFIX}${router} is not running"
            all_running=false
        fi
    done
    
    if [ "$all_running" = false ]; then
        log_error "Not all lab containers are running. Please deploy the lab first."
        echo ""
        echo "Deploy with: cd ospf-basics && sudo containerlab deploy -t topology.clab.yml"
        exit 1
    fi
    
    log_success "All lab containers are running"
    echo ""
    
    # Run exercises
    exercise_1
    echo ""
    
    exercise_2
    echo ""
    
    exercise_3
    echo ""
    
    exercise_4
    echo ""
    
    exercise_5
    echo ""
    
    # Output results
    echo "========================================="
    echo "Results Summary"
    echo "========================================="
    echo "Total Exercises: $EXERCISE_COUNT"
    echo "Passed: $PASSED_COUNT"
    echo "Failed: $FAILED_COUNT"
    echo ""
    
    # Save JSON results
    save_results "$LAB_NAME" "$OUTPUT_FILE"
    log_success "Results saved to: $OUTPUT_FILE"
    echo ""
    
    # Display JSON output
    echo "========================================="
    echo "JSON Output"
    echo "========================================="
    output_results "$LAB_NAME"
    echo ""
    
    # Exit with appropriate code
    if [ "$FAILED_COUNT" -eq 0 ]; then
        log_success "All exercises passed!"
        exit 0
    else
        log_error "Some exercises failed"
        exit 1
    fi
}

# Run main function
main "$@"
