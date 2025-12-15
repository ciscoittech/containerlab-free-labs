#!/bin/bash

echo "========================================="
echo "Linux Network Namespaces - Validation"
echo "========================================="
echo ""

PASSED=0
FAILED=0

# Test 1: Check if host1 can ping router
echo "Test 1: host1 -> router connectivity..."
if docker exec clab-netns-basics-host1 ping -c 2 10.0.1.1 >/dev/null 2>&1; then
    echo "  ✓ PASSED - host1 can ping router (10.0.1.1)"
    ((PASSED++))
else
    echo "  ✗ FAILED - host1 cannot ping router"
    ((FAILED++))
fi
echo ""

# Test 2: Check if host2 can ping router
echo "Test 2: host2 -> router connectivity..."
if docker exec clab-netns-basics-host2 ping -c 2 10.0.3.1 >/dev/null 2>&1; then
    echo "  ✓ PASSED - host2 can ping router (10.0.3.1)"
    ((PASSED++))
else
    echo "  ✗ FAILED - host2 cannot ping router"
    ((FAILED++))
fi
echo ""

# Test 3: Check if host1 and host2 can ping each other (via router)
echo "Test 3: host1 <-> host2 connectivity (via router)..."
if docker exec clab-netns-basics-host1 ping -c 2 10.0.3.20 >/dev/null 2>&1; then
    echo "  ✓ PASSED - host1 can ping host2 (10.0.3.20) via router"
    ((PASSED++))
else
    echo "  ✗ FAILED - host1 cannot ping host2"
    ((FAILED++))
fi
echo ""

# Test 4: Check if IP forwarding is enabled on router
echo "Test 4: IP forwarding on router..."
FORWARD=$(docker exec clab-netns-basics-router sysctl -n net.ipv4.ip_forward 2>/dev/null)
if [ "$FORWARD" -eq 1 ]; then
    echo "  ✓ PASSED - IP forwarding enabled on router"
    ((PASSED++))
else
    echo "  ✗ FAILED - IP forwarding disabled on router"
    ((FAILED++))
fi
echo ""

# Test 5: Check if host1 can reach host3 (different subnet)
echo "Test 5: host1 -> host3 connectivity (via router)..."
if docker exec clab-netns-basics-host1 ping -c 2 10.0.2.10 >/dev/null 2>&1; then
    echo "  ✓ PASSED - host1 can ping host3 (10.0.2.10) via router"
    ((PASSED++))
else
    echo "  ✗ FAILED - host1 cannot ping host3 (check routing)"
    ((FAILED++))
fi
echo ""

# Summary
echo "========================================="
echo "Validation Summary"
echo "========================================="
echo "Tests Passed: $PASSED"
echo "Tests Failed: $FAILED"
echo ""

if [ "$FAILED" -eq 0 ]; then
    echo "✓ All tests passed! Lab is working correctly."
    exit 0
else
    echo "✗ Some tests failed. Check network configuration."
    exit 1
fi
