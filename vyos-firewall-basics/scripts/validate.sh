#!/bin/bash
# Validation tests for VyOS Firewall Basics Lab

set -e

TOPOLOGY="vyos-firewall-basics"

# Color codes
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

TESTS_PASSED=0
TESTS_FAILED=0

test_header() {
    echo ""
    echo -e "${YELLOW}TEST: $1${NC}"
}

test_pass() {
    echo -e "${GREEN}✓ PASS${NC}"
    TESTS_PASSED=$((TESTS_PASSED + 1))
}

test_fail() {
    echo -e "${RED}✗ FAIL: $1${NC}"
    TESTS_FAILED=$((TESTS_FAILED + 1))
}

check_container_running() {
    docker ps --format '{{.Names}}' | grep -q "clab-${TOPOLOGY}-${1}"
}

echo "======================================"
echo "VyOS Firewall Basics Validation"
echo "======================================"

# Test 1: Containers running
test_header "Verify all containers are running"
ALL_RUNNING=true
for container in fw1 client1 internet; do
    if check_container_running "$container"; then
        echo "  ✓ $container is running"
    else
        echo "  ✗ $container is NOT running"
        ALL_RUNNING=false
    fi
done

if [ "$ALL_RUNNING" = true ]; then
    test_pass
else
    test_fail "Not all containers running"
fi

# Test 2: Zone configuration
test_header "Verify firewall zones configured"
if docker exec clab-${TOPOLOGY}-fw1 su - vyos -c "show firewall zone-policy zone wan" 2>/dev/null | grep -q "eth1" && \
   docker exec clab-${TOPOLOGY}-fw1 su - vyos -c "show firewall zone-policy zone lan" 2>/dev/null | grep -q "eth2"; then
    echo "  ✓ WAN zone (eth1) configured"
    echo "  ✓ LAN zone (eth2) configured"
    test_pass
else
    test_fail "Zone configuration incomplete"
fi

# Test 3: LAN → WAN allowed
test_header "Verify LAN → WAN traffic allowed"
if docker exec clab-${TOPOLOGY}-client1 ping -c 2 -W 3 172.16.10.100 > /dev/null 2>&1; then
    echo "  ✓ LAN client can ping WAN"
    test_pass
else
    test_fail "LAN → WAN blocked (should be allowed)"
fi

# Test 4: WAN → LAN blocked
test_header "Verify WAN → LAN traffic blocked"
if docker exec clab-${TOPOLOGY}-internet ping -c 2 -W 3 192.168.100.10 > /dev/null 2>&1; then
    test_fail "WAN can ping LAN (should be blocked)"
else
    echo "  ✓ WAN cannot ping LAN (correctly blocked)"
    test_pass
fi

# Test 5: Firewall statistics
test_header "Verify firewall statistics available"
if docker exec clab-${TOPOLOGY}-fw1 su - vyos -c "show firewall statistics" 2>/dev/null | grep -q "rule"; then
    echo "  ✓ Firewall statistics available"
    test_pass
else
    test_fail "Firewall statistics not available"
fi

# Summary
echo ""
echo "======================================"
echo "Test Summary"
echo "======================================"
echo -e "Passed: ${GREEN}${TESTS_PASSED}${NC}"
echo -e "Failed: ${RED}${TESTS_FAILED}${NC}"
echo "Total:  $((TESTS_PASSED + TESTS_FAILED))"

if [ $TESTS_FAILED -eq 0 ]; then
    echo ""
    echo -e "${GREEN}✓ All tests passed!${NC}"
    exit 0
else
    echo ""
    echo -e "${RED}✗ Some tests failed.${NC}"
    exit 1
fi
