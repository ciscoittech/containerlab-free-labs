#!/bin/bash

echo "========================================="
echo "BGP eBGP Basics Lab - Validation Tests"
echo "========================================="
echo ""

PASSED=0
FAILED=0

# Test 1: Check BGP neighbor on r1 (to r2)
echo "Test 1: Checking BGP neighbor on r1 (AS 100 -> AS 200)..."
# Check if neighbor shows prefix count (numeric) instead of state like Idle/Connect
if docker exec clab-bgp-ebgp-basics-r1 vtysh -c "show ip bgp summary" 2>/dev/null | grep "10.1.1.2" | grep -qE "[0-9]+\s+[0-9]+\s+N/A$"; then
    echo "  ✓ PASSED - r1 has established BGP session with AS 200"
    ((PASSED++))
else
    echo "  ✗ FAILED - r1 BGP session to AS 200 not established"
    ((FAILED++))
fi
echo ""

# Test 2: Check BGP neighbors on r2 (to r1 and r3)
echo "Test 2: Checking BGP neighbors on r2 (AS 200)..."
# Count neighbors with prefix count (established sessions show numeric PfxRcd)
NEIGHBORS=$(docker exec clab-bgp-ebgp-basics-r2 vtysh -c "show ip bgp summary" 2>/dev/null | grep -E "10\.[0-9]+\.[0-9]+\.[0-9]+.*[0-9]+\s+[0-9]+\s+N/A$" | wc -l)
if [ "$NEIGHBORS" -ge 2 ]; then
    echo "  ✓ PASSED - r2 has 2 established BGP sessions"
    ((PASSED++))
else
    echo "  ✗ FAILED - r2 expected 2 BGP sessions, found $NEIGHBORS"
    ((FAILED++))
fi
echo ""

# Test 3: Check if r1 learned routes from other AS
echo "Test 3: Checking if r1 learned BGP routes..."
ROUTES=$(docker exec clab-bgp-ebgp-basics-r1 vtysh -c "show ip bgp" 2>/dev/null | grep -c "192.168")
if [ "$ROUTES" -ge 3 ]; then
    echo "  ✓ PASSED - r1 has learned routes from BGP (found $ROUTES routes)"
    ((PASSED++))
else
    echo "  ✗ FAILED - r1 expected to learn at least 3 BGP routes, found $ROUTES"
    ((FAILED++))
fi
echo ""

# Test 4: Check if r4 can see routes from AS 300
echo "Test 4: Checking if r4 learned route to 192.168.3.0/24 (AS 300)..."
if docker exec clab-bgp-ebgp-basics-r4 vtysh -c "show ip bgp" 2>/dev/null | grep -q "192.168.3.0/24"; then
    echo "  ✓ PASSED - r4 learned route to 192.168.3.0/24"
    ((PASSED++))
else
    echo "  ✗ FAILED - r4 missing route to 192.168.3.0/24"
    ((FAILED++))
fi
echo ""

# Test 5: Verify AS-path on r1 for routes from AS 300
echo "Test 5: Checking AS-path on r1 for routes from AS 300..."
if docker exec clab-bgp-ebgp-basics-r1 vtysh -c "show ip bgp" 2>/dev/null | grep "192.168.3.0/24" | grep -q "200 300"; then
    echo "  ✓ PASSED - r1 sees correct AS-path (200 300) for AS 300 routes"
    ((PASSED++))
else
    echo "  ✗ FAILED - r1 AS-path incorrect for AS 300 routes"
    ((FAILED++))
fi
echo ""

# Test 6: Connectivity test (use loopback as source to ensure BGP routing)
echo "Test 6: Testing connectivity from r1 to r3's loopback..."
if docker exec clab-bgp-ebgp-basics-r1 ping -c 2 -I 192.168.1.1 192.168.3.1 >/dev/null 2>&1; then
    echo "  ✓ PASSED - r1 can ping 192.168.3.1 (r3)"
    ((PASSED++))
else
    echo "  ✗ FAILED - r1 cannot ping 192.168.3.1 (r3)"
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
    echo "✗ Some tests failed. Check BGP configuration."
    exit 1
fi
