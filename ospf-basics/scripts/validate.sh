#!/bin/bash

echo "========================================="
echo "OSPF Basics Lab - Validation Tests"
echo "========================================="
echo ""

PASSED=0
FAILED=0

# Test 1: Check OSPF neighbors on r1
echo "Test 1: Checking OSPF neighbors on r1..."
NEIGHBORS=$(docker exec clab-ospf-basics-r1 vtysh -c "show ip ospf neighbor" 2>/dev/null | grep -c "Full")
if [ "$NEIGHBORS" -eq 2 ]; then
    echo "  ✓ PASSED - r1 has 2 OSPF neighbors in Full state"
    ((PASSED++))
else
    echo "  ✗ FAILED - r1 expected 2 neighbors, found $NEIGHBORS"
    ((FAILED++))
fi
echo ""

# Test 2: Check OSPF neighbors on r2
echo "Test 2: Checking OSPF neighbors on r2..."
NEIGHBORS=$(docker exec clab-ospf-basics-r2 vtysh -c "show ip ospf neighbor" 2>/dev/null | grep -c "Full")
if [ "$NEIGHBORS" -eq 2 ]; then
    echo "  ✓ PASSED - r2 has 2 OSPF neighbors in Full state"
    ((PASSED++))
else
    echo "  ✗ FAILED - r2 expected 2 neighbors, found $NEIGHBORS"
    ((FAILED++))
fi
echo ""

# Test 3: Check OSPF neighbors on r3
echo "Test 3: Checking OSPF neighbors on r3..."
NEIGHBORS=$(docker exec clab-ospf-basics-r3 vtysh -c "show ip ospf neighbor" 2>/dev/null | grep -c "Full")
if [ "$NEIGHBORS" -eq 2 ]; then
    echo "  ✓ PASSED - r3 has 2 OSPF neighbors in Full state"
    ((PASSED++))
else
    echo "  ✗ FAILED - r3 expected 2 neighbors, found $NEIGHBORS"
    ((FAILED++))
fi
echo ""

# Test 4: Check if r1 has routes to 192.168.100.0/24
echo "Test 4: Checking if r1 learned route to 192.168.100.0/24..."
if docker exec clab-ospf-basics-r1 vtysh -c "show ip route" 2>/dev/null | grep -q "192.168.100.0/24"; then
    echo "  ✓ PASSED - r1 has route to 192.168.100.0/24"
    ((PASSED++))
else
    echo "  ✗ FAILED - r1 missing route to 192.168.100.0/24"
    ((FAILED++))
fi
echo ""

# Test 5: Check if r2 has routes to 192.168.100.0/24
echo "Test 5: Checking if r2 learned route to 192.168.100.0/24..."
if docker exec clab-ospf-basics-r2 vtysh -c "show ip route" 2>/dev/null | grep -q "192.168.100.0/24"; then
    echo "  ✓ PASSED - r2 has route to 192.168.100.0/24"
    ((PASSED++))
else
    echo "  ✗ FAILED - r2 missing route to 192.168.100.0/24"
    ((FAILED++))
fi
echo ""

# Test 6: Ping test from r1 to r3's loopback
echo "Test 6: Testing connectivity from r1 to 192.168.100.1..."
if docker exec clab-ospf-basics-r1 ping -c 2 192.168.100.1 >/dev/null 2>&1; then
    echo "  ✓ PASSED - r1 can ping 192.168.100.1"
    ((PASSED++))
else
    echo "  ✗ FAILED - r1 cannot ping 192.168.100.1"
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
    echo "✗ Some tests failed. Check OSPF configuration."
    exit 1
fi
