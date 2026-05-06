#!/bin/bash

# VyOS Firewall Basics Lab - Student Exercises Script
# Simulates a student walking through the firewall lab exercises

set -e

# Get script directory for sourcing libs
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PARENT_DIR="$(dirname "$SCRIPT_DIR")"

# Source common libraries
source "${PARENT_DIR}/lib/common.sh"
source "${PARENT_DIR}/lib/result-collector.sh"

# Lab configuration
LAB_NAME="vyos-firewall-basics"
CONTAINER_PREFIX="clab-${LAB_NAME}-"

# Container names
FW1="${CONTAINER_PREFIX}fw1"
CLIENT1="${CONTAINER_PREFIX}client1"
INTERNET="${CONTAINER_PREFIX}internet"

# IP addresses
CLIENT1_IP="192.168.100.10"
INTERNET_IP="172.16.10.100"
FW1_WAN_IP="172.16.10.1"
FW1_LAN_IP="192.168.100.1"

log_info "========================================="
log_info "VyOS Firewall Basics - Student Exercises"
log_info "========================================="
echo ""

# Initialize results collection
init_results "${PARENT_DIR}/results"
start_lab_results "$LAB_NAME"

# Verify all containers are running
log_info "Verifying lab containers..."
if verify_lab_containers "$LAB_NAME" "fw1" "client1" "internet"; then
    pass_test "Container Verification" "All lab containers are running"
else
    fail_test "Container Verification" "One or more containers not running"
    finalize_lab_results
    exit 1
fi
echo ""

# Exercise 1: LAN to WAN Traffic
log_info "Exercise 1: Testing LAN to WAN traffic (client1 → internet)"
if run_docker_cmd "$CLIENT1" "ping -c 2 -W 3 ${INTERNET_IP}" > /dev/null 2>&1; then
    pass_test "Exercise 1: LAN to WAN" "Client can ping internet (LAN→WAN allowed)"
else
    fail_test "Exercise 1: LAN to WAN" "Client cannot ping internet" "Ping from ${CLIENT1_IP} to ${INTERNET_IP} failed"
fi
echo ""

# Exercise 2: WAN to LAN Traffic
log_info "Exercise 2: Testing WAN to LAN traffic (internet → client1)"
if run_docker_cmd "$INTERNET" "ping -c 2 -W 3 ${CLIENT1_IP}" > /dev/null 2>&1; then
    pass_test "Exercise 2: WAN to LAN" "Internet can ping client (bidirectional routing works)"
else
    fail_test "Exercise 2: WAN to LAN" "Internet cannot ping client" "Ping from ${INTERNET_IP} to ${CLIENT1_IP} failed"
fi
echo ""

# Exercise 3: Verify VyOS Interfaces
log_info "Exercise 3: Verifying VyOS interface configuration"

# Check WAN interface (eth1)
wan_check=false
if run_docker_cmd "$FW1" "ip addr show eth1" 2>/dev/null | grep -q "${FW1_WAN_IP}"; then
    log_success "  WAN interface (eth1) has ${FW1_WAN_IP}"
    wan_check=true
else
    log_error "  WAN interface (eth1) missing ${FW1_WAN_IP}"
fi

# Check LAN interface (eth2)
lan_check=false
if run_docker_cmd "$FW1" "ip addr show eth2" 2>/dev/null | grep -q "${FW1_LAN_IP}"; then
    log_success "  LAN interface (eth2) has ${FW1_LAN_IP}"
    lan_check=true
else
    log_error "  LAN interface (eth2) missing ${FW1_LAN_IP}"
fi

if [ "$wan_check" = true ] && [ "$lan_check" = true ]; then
    pass_test "Exercise 3: Interface Configuration" "Both WAN and LAN interfaces configured correctly"
else
    fail_test "Exercise 3: Interface Configuration" "One or more interfaces not configured properly"
fi
echo ""

# Exercise 4: IP Forwarding
log_info "Exercise 4: Verifying IP forwarding is enabled"
ip_forward=$(run_docker_cmd "$FW1" "cat /proc/sys/net/ipv4/ip_forward" 2>/dev/null | tr -d '[:space:]')

if [ "$ip_forward" = "1" ]; then
    log_success "  IP forwarding is enabled (value: 1)"
    pass_test "Exercise 4: IP Forwarding" "IP forwarding enabled on firewall"
else
    log_error "  IP forwarding is disabled (value: ${ip_forward})"
    fail_test "Exercise 4: IP Forwarding" "IP forwarding not enabled" "Expected: 1, Got: ${ip_forward}"
fi
echo ""

# Exercise 5: Routing Verification
log_info "Exercise 5: Verifying client routing configuration"

# Check for default route on client1
route_output=$(run_docker_cmd "$CLIENT1" "ip route" 2>/dev/null)
if echo "$route_output" | grep -q "default via ${FW1_LAN_IP}"; then
    log_success "  Client has default route via ${FW1_LAN_IP}"
    pass_test "Exercise 5: Routing Verification" "Client has correct default route"
else
    log_error "  Client missing default route via ${FW1_LAN_IP}"
    fail_test "Exercise 5: Routing Verification" "Default route not configured" "Expected: default via ${FW1_LAN_IP}"
fi
echo ""

# Finalize and write results
finalize_lab_results

log_info "========================================="
log_info "Student exercises completed!"
log_info "Results written to: ${RESULTS_DIR}"
log_info "========================================="
