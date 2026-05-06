#!/bin/bash

# Student test script for Linux Network Namespaces Lab
# Simulates a student walking through the lab exercises

# Get the directory of this script
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
LIB_DIR="$(dirname "$SCRIPT_DIR")/lib"

# Source library files
source "$LIB_DIR/common.sh"
source "$LIB_DIR/result-collector.sh"

# Lab configuration
LAB_NAME="linux-network-namespaces"
CONTAINER_PREFIX="clab-netns-basics-"

# Container names
ROUTER="${CONTAINER_PREFIX}router"
HOST1="${CONTAINER_PREFIX}host1"
HOST2="${CONTAINER_PREFIX}host2"
HOST3="${CONTAINER_PREFIX}host3"

log_info "Starting Linux Network Namespaces Lab student exercises..."
echo ""

#############################################
# Exercise 1: Understanding Namespaces (doc check)
#############################################
log_info "Exercise 1: Understanding Namespaces"

# Check if all containers are running
all_running=true
for container in "$ROUTER" "$HOST1" "$HOST2" "$HOST3"; do
    if ! check_container "$container"; then
        all_running=false
        log_error "Container $container is not running"
    fi
done

if [ "$all_running" = true ]; then
    add_result 1 "Understanding Namespaces" "passed" \
        "All containers (router, host1, host2, host3) running" \
        "All containers running" \
        "Verified all 4 containers are operational"
    log_success "All containers are running"
else
    add_result 1 "Understanding Namespaces" "failed" \
        "All containers running" \
        "Some containers not running" \
        "One or more containers failed to start"
    log_error "Some containers are not running"
fi
echo ""

#############################################
# Exercise 2: Explore Namespace
#############################################
log_info "Exercise 2: Explore Namespace"

# Check host1 IP address
ip_output=$(docker exec "$HOST1" ip addr show eth1 2>/dev/null)
if echo "$ip_output" | grep -q "10.0.1.10/24"; then
    add_result 2 "Explore Namespace - IP Address" "passed" \
        "eth1 interface with IP 10.0.1.10/24" \
        "Found 10.0.1.10/24 on eth1" \
        "Host1 has correct IP configuration"
    log_success "host1 has correct IP: 10.0.1.10/24"
else
    add_result 2 "Explore Namespace - IP Address" "failed" \
        "eth1 interface with IP 10.0.1.10/24" \
        "IP not found or incorrect" \
        "Expected IP 10.0.1.10/24 on eth1"
    log_error "host1 IP configuration incorrect"
fi

# Check host1 routing table
route_output=$(docker exec "$HOST1" ip route show 2>/dev/null)
if echo "$route_output" | grep -q "default via 10.0.1.1"; then
    add_result 2 "Explore Namespace - Default Route" "passed" \
        "default via 10.0.1.1" \
        "Found default route via 10.0.1.1" \
        "Host1 has correct default gateway"
    log_success "host1 has correct default route via 10.0.1.1"
else
    add_result 2 "Explore Namespace - Default Route" "failed" \
        "default via 10.0.1.1" \
        "Default route not found or incorrect" \
        "Expected default route via 10.0.1.1"
    log_error "host1 default route incorrect"
fi
echo ""

#############################################
# Exercise 3: Veth Pairs
#############################################
log_info "Exercise 3: Veth Pairs"

# Check router interfaces
link_output=$(docker exec "$ROUTER" ip link show 2>/dev/null)
interfaces_found=0

for iface in eth1 eth2 eth3; do
    if echo "$link_output" | grep -q "$iface"; then
        ((interfaces_found++))
    fi
done

if [ $interfaces_found -eq 3 ]; then
    add_result 3 "Veth Pairs" "passed" \
        "eth1, eth2, eth3 interfaces present on router" \
        "Found all 3 interfaces (eth1, eth2, eth3)" \
        "Router has all expected veth interfaces"
    log_success "Router has all 3 interfaces: eth1, eth2, eth3"
else
    add_result 3 "Veth Pairs" "failed" \
        "eth1, eth2, eth3 interfaces present" \
        "Found $interfaces_found of 3 interfaces" \
        "Missing one or more expected interfaces"
    log_error "Router missing interfaces (found $interfaces_found of 3)"
fi
echo ""

#############################################
# Exercise 4: Test Connectivity
#############################################
log_info "Exercise 4: Test Connectivity"

# Test host1 -> host2 (10.0.3.20)
if docker exec "$HOST1" ping -c 2 -W 2 10.0.3.20 >/dev/null 2>&1; then
    add_result 4 "Connectivity - host1 to host2" "passed" \
        "Ping from host1 to host2 (10.0.3.20) succeeds" \
        "Ping successful" \
        "host1 can reach host2 via router"
    log_success "host1 can ping host2 (10.0.3.20)"
else
    add_result 4 "Connectivity - host1 to host2" "failed" \
        "Ping from host1 to host2 succeeds" \
        "Ping failed" \
        "Cannot reach host2 from host1"
    log_error "host1 cannot ping host2"
fi

# Test host1 -> host3 (10.0.2.10)
if docker exec "$HOST1" ping -c 2 -W 2 10.0.2.10 >/dev/null 2>&1; then
    add_result 4 "Connectivity - host1 to host3" "passed" \
        "Ping from host1 to host3 (10.0.2.10) succeeds" \
        "Ping successful" \
        "host1 can reach host3 via router"
    log_success "host1 can ping host3 (10.0.2.10)"
else
    add_result 4 "Connectivity - host1 to host3" "failed" \
        "Ping from host1 to host3 succeeds" \
        "Ping failed" \
        "Cannot reach host3 from host1"
    log_error "host1 cannot ping host3"
fi

# Test host2 -> host3 (10.0.2.10)
if docker exec "$HOST2" ping -c 2 -W 2 10.0.2.10 >/dev/null 2>&1; then
    add_result 4 "Connectivity - host2 to host3" "passed" \
        "Ping from host2 to host3 (10.0.2.10) succeeds" \
        "Ping successful" \
        "host2 can reach host3 via router"
    log_success "host2 can ping host3 (10.0.2.10)"
else
    add_result 4 "Connectivity - host2 to host3" "failed" \
        "Ping from host2 to host3 succeeds" \
        "Ping failed" \
        "Cannot reach host3 from host2"
    log_error "host2 cannot ping host3"
fi
echo ""

#############################################
# Exercise 5: IP Forwarding
#############################################
log_info "Exercise 5: IP Forwarding"

# Check IP forwarding on router
forward_value=$(docker exec "$ROUTER" cat /proc/sys/net/ipv4/ip_forward 2>/dev/null)

if [ "$forward_value" = "1" ]; then
    add_result 5 "IP Forwarding" "passed" \
        "IP forwarding enabled (value = 1)" \
        "IP forwarding = $forward_value" \
        "Router is configured to forward packets between interfaces"
    log_success "IP forwarding is enabled on router"
else
    add_result 5 "IP Forwarding" "failed" \
        "IP forwarding enabled (value = 1)" \
        "IP forwarding = $forward_value" \
        "IP forwarding is disabled, router cannot forward packets"
    log_error "IP forwarding is disabled on router"
fi
echo ""

#############################################
# Exercise 6: Routing Tables
#############################################
log_info "Exercise 6: Routing Tables"

# Check host3 routing table
host3_routes=$(docker exec "$HOST3" ip route show 2>/dev/null)

if echo "$host3_routes" | grep -q "default via 10.0.2.1"; then
    add_result 6 "Routing Tables" "passed" \
        "Default route via 10.0.2.1 on host3" \
        "Found default route via 10.0.2.1" \
        "host3 knows to send unknown destinations to router"
    log_success "host3 has correct default route via 10.0.2.1"
else
    add_result 6 "Routing Tables" "failed" \
        "Default route via 10.0.2.1" \
        "Default route not found or incorrect" \
        "host3 missing or incorrect default route"
    log_error "host3 routing table incorrect"
fi
echo ""

#############################################
# Exercise 7: Packet Capture Ready
#############################################
log_info "Exercise 7: Packet Capture Ready"

# Check if tcpdump is available (optional - may not be installed)
if docker exec "$ROUTER" which tcpdump >/dev/null 2>&1; then
    add_result 7 "Packet Capture Ready" "passed" \
        "tcpdump available for packet capture" \
        "tcpdump found on router" \
        "Router has tcpdump installed for network analysis"
    log_success "tcpdump is available on router"
else
    # This is informational, not a failure
    add_result 7 "Packet Capture Ready" "passed" \
        "tcpdump availability check" \
        "tcpdump not installed (can be added with: apk add tcpdump)" \
        "tcpdump can be installed if needed for packet capture exercises"
    log_warning "tcpdump not installed (optional - can be added with: apk add tcpdump)"
fi
echo ""

#############################################
# Output Results
#############################################
log_info "Generating results..."
echo ""

# Output JSON results to stdout
output_results "$LAB_NAME"

# Also save to results directory
RESULTS_DIR="$(dirname "$SCRIPT_DIR")/results"
mkdir -p "$RESULTS_DIR"
OUTPUT_FILE="$RESULTS_DIR/${LAB_NAME}-results.json"
save_results "$LAB_NAME" "$OUTPUT_FILE"

echo ""
log_info "Results saved to: $OUTPUT_FILE"
echo ""

# Exit with appropriate code
if [ $FAILED_COUNT -eq 0 ]; then
    log_success "All exercises passed! ($PASSED_COUNT/$EXERCISE_COUNT)"
    exit 0
else
    log_error "Some exercises failed. Passed: $PASSED_COUNT/$EXERCISE_COUNT, Failed: $FAILED_COUNT"
    exit 1
fi
