#!/bin/bash
# Zero Trust Fundamentals - Validation Tests
#
# Tests the Zero Trust microservices architecture:
# - Identity service (JWT authentication)
# - Web service (protected API)
# - MongoDB (data store)

echo "========================================="
echo "Zero Trust Fundamentals - Validation"
echo "========================================="
echo ""

PASSED=0
FAILED=0

# Test 1: Check containers running
echo "Test 1: Checking containers are running..."
MONGODB_RUNNING=$(docker ps --format '{{.Names}}' | grep -c "zt-mongodb" || true)
IDENTITY_RUNNING=$(docker ps --format '{{.Names}}' | grep -c "zt-identity" || true)
WEB_RUNNING=$(docker ps --format '{{.Names}}' | grep -c "zt-web" || true)

if [[ "$MONGODB_RUNNING" -ge 1 && "$IDENTITY_RUNNING" -ge 1 && "$WEB_RUNNING" -ge 1 ]]; then
    echo "  PASSED - All containers running"
    ((PASSED++))
else
    echo "  FAILED - Missing containers (mongodb=$MONGODB_RUNNING, identity=$IDENTITY_RUNNING, web=$WEB_RUNNING)"
    ((FAILED++))
fi
echo ""

# Test 2: Identity service health
echo "Test 2: Identity service health check..."
IDENTITY_HEALTH=$(curl -s -m 5 http://localhost:8443/health 2>/dev/null || echo "")
if echo "$IDENTITY_HEALTH" | grep -qiE '"status":\s*"(ok|healthy)"'; then
    echo "  PASSED - Identity service healthy"
    ((PASSED++))
else
    echo "  FAILED - Identity service not healthy (response: $IDENTITY_HEALTH)"
    ((FAILED++))
fi
echo ""

# Test 3: Web service health
echo "Test 3: Web service health check..."
WEB_HEALTH=$(curl -s -m 5 http://localhost:8080/health 2>/dev/null || echo "")
if echo "$WEB_HEALTH" | grep -qiE '"status":\s*"(ok|healthy)"'; then
    echo "  PASSED - Web service healthy"
    ((PASSED++))
else
    echo "  FAILED - Web service not healthy (response: $WEB_HEALTH)"
    ((FAILED++))
fi
echo ""

# Test 4: Unauthorized access blocked
echo "Test 4: Protected endpoint blocks unauthorized access..."
HTTP_CODE=$(curl -s -o /dev/null -w "%{http_code}" -m 5 http://localhost:8080/api/profile 2>/dev/null || echo "000")
if [[ "$HTTP_CODE" == "401" || "$HTTP_CODE" == "403" ]]; then
    echo "  PASSED - Correctly returned HTTP $HTTP_CODE (unauthorized)"
    ((PASSED++))
else
    echo "  FAILED - Got HTTP $HTTP_CODE (expected 401 or 403)"
    ((FAILED++))
fi
echo ""

# Test 5: Authentication flow works
echo "Test 5: Full authentication flow..."

# Step 5a: Login to get token
LOGIN_RESPONSE=$(curl -s -m 10 -X POST http://localhost:8443/auth/login \
    -H "Content-Type: application/json" \
    -d '{"username": "alice", "password": "password123"}' 2>/dev/null || echo "{}")

# Try to extract token (handles both access_token and token field names)
TOKEN=""
if command -v python3 &>/dev/null; then
    TOKEN=$(echo "$LOGIN_RESPONSE" | python3 -c "
import sys, json
try:
    data = json.load(sys.stdin)
    print(data.get('access_token', data.get('token', '')))
except:
    print('')
" 2>/dev/null)
elif command -v jq &>/dev/null; then
    TOKEN=$(echo "$LOGIN_RESPONSE" | jq -r '.access_token // .token // ""' 2>/dev/null)
fi

if [[ -n "$TOKEN" && "$TOKEN" != "null" ]]; then
    # Step 5b: Access protected endpoint with token
    PROFILE_CODE=$(curl -s -o /dev/null -w "%{http_code}" -m 5 http://localhost:8080/api/profile \
        -H "Authorization: Bearer $TOKEN" 2>/dev/null || echo "000")

    if [[ "$PROFILE_CODE" == "200" ]]; then
        echo "  PASSED - Auth flow complete (login + protected access)"
        ((PASSED++))
    else
        echo "  FAILED - Token obtained but protected endpoint returned HTTP $PROFILE_CODE"
        ((FAILED++))
    fi
else
    echo "  FAILED - Could not obtain auth token"
    echo "    Login response: $LOGIN_RESPONSE"
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

if [[ "$FAILED" -eq 0 ]]; then
    echo "All tests passed!"
    exit 0
else
    echo "Some tests failed."
    exit 1
fi
