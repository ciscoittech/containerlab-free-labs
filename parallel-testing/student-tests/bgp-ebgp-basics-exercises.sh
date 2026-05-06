#!/bin/bash

#############################################################################
# BGP eBGP Basics Lab - Student Exercise Simulation
#
# This script simulates a student walking through the BGP eBGP basics lab
# exercises and validates their work. It uses docker exec commands to
# interact with the lab containers.
#
# Container prefix: clab-bgp-ebgp-basics-
# Routers: r1, r2, r3, r4
#############################################################################

# Get script directory and source libraries
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
LIB_DIR="$(dirname "$SCRIPT_DIR")/lib"

# Source library files
source "$LIB_DIR/common.sh"
source "$LIB_DIR/result-collector.sh"

# Lab configuration
LAB_NAME="bgp-ebgp-basics"
CONTAINER_PREFIX="clab-bgp-ebgp-basics-"

#############################################################################
# Helper Functions
#############################################################################

# Execute vtysh command in container
exec_vtysh() {
    local container=$1
    local cmd=$2
    docker exec "$container" vtysh -c "$cmd" 2>/dev/null
}

#############################################################################
# Exercise Functions
#############################################################################

# Exercise 1: Verify BGP Neighbors
exercise_1() {
    log_info "Exercise 1: Verify BGP Neighbors on r2"
    
    local container="${CONTAINER_PREFIX}r2"
    local expected="2 established BGP sessions"
    
    if ! check_container "$container"; then
        add_exercise_result "Exercise 1: Verify BGP Neighbors" "failed" "Container $container is not running"
        return 1
    fi
    
    # Run the command
    local output
    output=$(exec_vtysh "$container" "show ip bgp summary")
    
    # Check for established sessions (numeric prefix count pattern)
    local established
    established=$(echo "$output" | grep -E "10\.[0-9]+\.[0-9]+\.[0-9]+.*[0-9]+\s+[0-9]+\s+N/A$" | wc -l | tr -d ' ')
    
    if [ "$established" -ge 2 ]; then
        add_exercise_result "Exercise 1: Verify BGP Neighbors" "passed" "Found $established established BGP sessions" "r2 peers with r1 (AS 100) and r3 (AS 300)"
        return 0
    else
        add_exercise_result "Exercise 1: Verify BGP Neighbors" "failed" "Found $established established BGP sessions" "Expected 2 established sessions"
        return 1
    fi
}

# Exercise 2: View BGP Routes
exercise_2() {
    log_info "Exercise 2: View BGP Routes on r1"
    
    local container="${CONTAINER_PREFIX}r1"
    
    if ! check_container "$container"; then
        add_exercise_result "Exercise 2: View BGP Routes" "failed" "Container $container is not running"
        return 1
    fi
    
    # Run the command
    local output
    output=$(exec_vtysh "$container" "show ip bgp")
    
    # Count routes with 192.168 prefix
    local route_count
    route_count=$(echo "$output" | grep -c "192.168")
    
    if [ "$route_count" -ge 4 ]; then
        add_exercise_result "Exercise 2: View BGP Routes" "passed" "Found $route_count routes with 192.168 prefix" "Expected: 192.168.1.0/24, 192.168.2.0/24, 192.168.3.0/24, 192.168.4.0/24"
        return 0
    else
        add_exercise_result "Exercise 2: View BGP Routes" "failed" "Found $route_count routes with 192.168 prefix" "Expected at least 4 routes"
        return 1
    fi
}

# Exercise 3: AS-Path Analysis
exercise_3() {
    log_info "Exercise 3: AS-Path Analysis on r1 for 192.168.3.0/24"
    
    local container="${CONTAINER_PREFIX}r1"
    local target_route="192.168.3.0/24"
    
    if ! check_container "$container"; then
        add_exercise_result "Exercise 3: AS-Path Analysis" "failed" "Container $container is not running"
        return 1
    fi
    
    # Run the command
    local output
    output=$(exec_vtysh "$container" "show ip bgp $target_route")
    
    # Check for AS-path pattern
    if echo "$output" | grep -q "200 300"; then
        add_exercise_result "Exercise 3: AS-Path Analysis" "passed" "AS-path contains '200 300'" "Correct AS-path from AS 100 to AS 300"
        return 0
    else
        add_exercise_result "Exercise 3: AS-Path Analysis" "failed" "AS-path does not contain '200 300'" "Expected AS-path: 200 300"
        return 1
    fi
}

# Exercise 4: BGP Attributes
exercise_4() {
    log_info "Exercise 4: Check BGP Attributes for 192.168.2.0/24 on r1"
    
    local container="${CONTAINER_PREFIX}r1"
    local target_route="192.168.2.0/24"
    
    if ! check_container "$container"; then
        add_exercise_result "Exercise 4: BGP Attributes" "failed" "Container $container is not running"
        return 1
    fi
    
    # Run the command
    local output
    output=$(exec_vtysh "$container" "show ip bgp $target_route")
    
    # Check for next-hop and origin
    local has_nexthop=false
    local has_origin=false
    
    if echo "$output" | grep -qiE "Next Hop|next.hop"; then
        has_nexthop=true
    fi
    
    if echo "$output" | grep -qiE "Origin|origin.*IGP|, i,"; then
        has_origin=true
    fi
    
    if [ "$has_nexthop" = true ] && [ "$has_origin" = true ]; then
        add_exercise_result "Exercise 4: BGP Attributes" "passed" "Next-hop and origin (IGP) attributes found" "BGP attributes visible"
        return 0
    elif [ "$has_nexthop" = true ]; then
        add_exercise_result "Exercise 4: BGP Attributes" "passed" "Next-hop found, origin unclear" "Next-hop attribute visible"
        return 0
    else
        add_exercise_result "Exercise 4: BGP Attributes" "failed" "BGP attributes not found or incomplete" "Could not verify next-hop and origin attributes"
        return 1
    fi
}

# Exercise 5: Path Selection
exercise_5() {
    log_info "Exercise 5: Verify r4 can see route to AS 100 (192.168.1.0/24)"
    
    local container="${CONTAINER_PREFIX}r4"
    local target_route="192.168.1.0/24"
    
    if ! check_container "$container"; then
        add_exercise_result "Exercise 5: Path Selection" "failed" "Container $container is not running"
        return 1
    fi
    
    # Run the command
    local output
    output=$(exec_vtysh "$container" "show ip bgp")
    
    if echo "$output" | grep -q "$target_route"; then
        add_exercise_result "Exercise 5: Path Selection" "passed" "Route to $target_route visible" "r4 can see route to AS 100"
        return 0
    else
        add_exercise_result "Exercise 5: Path Selection" "failed" "Route to $target_route not found" "Route not propagated to r4"
        return 1
    fi
}

# Exercise 6: Connectivity Test
exercise_6() {
    log_info "Exercise 6: Test connectivity from r1 to r3 loopback (192.168.3.1)"
    
    local container="${CONTAINER_PREFIX}r1"
    local source_ip="192.168.1.1"
    local target_ip="192.168.3.1"
    
    if ! check_container "$container"; then
        add_exercise_result "Exercise 6: Connectivity Test" "failed" "Container $container is not running"
        return 1
    fi
    
    # Run ping test
    if docker exec "$container" ping -c 2 -I "$source_ip" "$target_ip" >/dev/null 2>&1; then
        add_exercise_result "Exercise 6: Connectivity Test" "passed" "Ping successful (2 packets received)" "End-to-end connectivity from $source_ip to $target_ip verified"
        return 0
    else
        add_exercise_result "Exercise 6: Connectivity Test" "failed" "Ping failed" "No connectivity from r1 to r3"
        return 1
    fi
}

#############################################################################
# Main Execution
#############################################################################

main() {
    echo "========================================="
    echo "BGP eBGP Basics - Student Exercise Simulation"
    echo "========================================="
    echo ""
    
    # Initialize results
    local results_dir="$(dirname "$SCRIPT_DIR")/results"
    init_results "$results_dir"
    
    # Start lab result collection
    start_lab_results "$LAB_NAME"
    
    # Verify lab is running
    log_info "Checking if lab containers are running..."
    local all_running=true
    
    for router in r1 r2 r3 r4; do
        if ! check_container "${CONTAINER_PREFIX}${router}"; then
            log_error "Container ${CONTAINER_PREFIX}${router} is not running"
            all_running=false
        fi
    done
    
    if [ "$all_running" = false ]; then
        log_error "Not all lab containers are running. Please deploy the lab first."
        echo ""
        echo "Deploy with: cd bgp-ebgp-basics && sudo containerlab deploy -t topology.clab.yml"
        
        # Add skipped results for all exercises
        for i in {1..6}; do
            add_exercise_result "Exercise $i" "skipped" "Lab not deployed"
        done
        
        finalize_lab_results
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
    
    exercise_6
    echo ""
    
    # Finalize results
    finalize_lab_results
    
    # Generate summary
    generate_summary
    
    # Count failures for exit code
    local lab_result_file="${RESULTS_DIR}/${LAB_NAME}.json"
    local failed_count
    failed_count=$(grep -c '"status": "failed"' "$lab_result_file" 2>/dev/null || echo "0")
    
    echo ""
    echo "========================================="
    echo "Test Complete"
    echo "========================================="
    
    # Exit with appropriate code
    if [ "$failed_count" -eq 0 ]; then
        log_success "All exercises passed!"
        exit 0
    else
        log_error "Some exercises failed ($failed_count)"
        exit 1
    fi
}

# Run main function
main "$@"
