#!/bin/bash
# Zero Trust Fundamentals - Student Exercises
#
# Simulates a student walking through the zero-trust fundamentals lab.
# Tests the authentication flow and protected endpoints.
#
# Container prefix: clab-zero-trust-fundamentals-
# API Gateway: localhost:8500 (HTTP), localhost:8543 (HTTPS)

set -e

# Get script directory and source libraries
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
LIB_DIR="$(dirname "$SCRIPT_DIR")/lib"

# Source library files
source "$LIB_DIR/common.sh"
source "$LIB_DIR/result-collector.sh"

LAB_NAME="zero-trust-fundamentals"

echo "========================================="
echo "Zero Trust Fundamentals - Student Exercises"
echo "========================================="
echo ""

# Exercise 1: Public Endpoint
echo "Exercise 1: Testing public endpoint..."
log_info "Accessing root endpoint (no auth required)"

PUBLIC_RESPONSE=$(curl -s -m 5 http://localhost:8500/ 2>/dev/null || echo "")

if [ -n "$PUBLIC_RESPONSE" ]; then
    # Check if response is valid JSON or has content
    if echo "$PUBLIC_RESPONSE" | grep -qE '(\{.*\}|\[.*\]|welcome|api|info)'; then
        log_info "Success: Received response from public endpoint"
        add_test_result "Exercise 1: Public Endpoint" "pass" "Successfully accessed public endpoint" "$PUBLIC_RESPONSE"
    else
        log_error "Unexpected response format"
        add_test_result "Exercise 1: Public Endpoint" "fail" "Received unexpected response" "$PUBLIC_RESPONSE"
    fi
else
    log_error "No response from public endpoint"
    add_test_result "Exercise 1: Public Endpoint" "fail" "No response from http://localhost:8500/"
fi
echo ""

# Exercise 2: Protected Without Auth
echo "Exercise 2: Accessing protected endpoint without authentication..."
log_info "Attempting to access /api/profile without token"

UNAUTH_CODE=$(curl -s -o /dev/null -w "%{http_code}" -m 5 http://localhost:8500/api/profile 2>/dev/null || echo "000")

if [ "$UNAUTH_CODE" = "401" ]; then
    log_info "Success: Got 401 Unauthorized (expected)"
    add_test_result "Exercise 2: Protected Without Auth" "pass" "Correctly blocked with HTTP 401" "HTTP $UNAUTH_CODE"
elif [ "$UNAUTH_CODE" = "403" ]; then
    log_info "Success: Got 403 Forbidden (also acceptable)"
    add_test_result "Exercise 2: Protected Without Auth" "pass" "Correctly blocked with HTTP 403" "HTTP $UNAUTH_CODE"
else
    log_error "Unexpected HTTP code: $UNAUTH_CODE (expected 401)"
    add_test_result "Exercise 2: Protected Without Auth" "fail" "Expected HTTP 401, got $UNAUTH_CODE" "HTTP $UNAUTH_CODE"
fi
echo ""

# Exercise 3: Login
echo "Exercise 3: Logging in to obtain authentication token..."
log_info "POST /auth/login with demo credentials"

LOGIN_RESPONSE=$(curl -s -m 10 -X POST http://localhost:8500/auth/login \
    -H "Content-Type: application/json" \
    -d '{"username":"demo","password":"demo123"}' 2>/dev/null || echo "{}")

# Extract token (try multiple field names)
TOKEN=""
if command -v jq &>/dev/null; then
    TOKEN=$(echo "$LOGIN_RESPONSE" | jq -r '.token // .access_token // .jwt // empty' 2>/dev/null)
elif command -v python3 &>/dev/null; then
    TOKEN=$(echo "$LOGIN_RESPONSE" | python3 -c "
import sys, json
try:
    data = json.load(sys.stdin)
    token = data.get('token') or data.get('access_token') or data.get('jwt') or ''
    print(token)
except:
    print('')
" 2>/dev/null)
fi

if [ -n "$TOKEN" ] && [ "$TOKEN" != "null" ]; then
    log_info "Success: Obtained authentication token"
    # Show token structure (should be JWT with 3 parts)
    TOKEN_PARTS=$(echo "$TOKEN" | tr '.' '\n' | wc -l | tr -d ' ')
    log_info "Token has $TOKEN_PARTS parts (JWT tokens have 3)"
    add_test_result "Exercise 3: Login" "pass" "Successfully obtained auth token" "Token parts: $TOKEN_PARTS"
else
    log_error "Failed to obtain token"
    add_test_result "Exercise 3: Login" "fail" "Could not extract token from login response" "$LOGIN_RESPONSE"
    TOKEN=""  # Clear token to prevent using invalid value
fi
echo ""

# Exercise 4: Protected With Auth
echo "Exercise 4: Accessing protected endpoint with authentication..."

if [ -n "$TOKEN" ]; then
    log_info "GET /api/profile with Bearer token"

    AUTH_CODE=$(curl -s -o /dev/null -w "%{http_code}" -m 5 http://localhost:8500/api/profile \
        -H "Authorization: Bearer $TOKEN" 2>/dev/null || echo "000")

    if [ "$AUTH_CODE" = "200" ]; then
        log_info "Success: Got 200 OK with valid token"
        add_test_result "Exercise 4: Protected With Auth" "pass" "Successfully accessed protected endpoint" "HTTP $AUTH_CODE"
    else
        log_error "Unexpected HTTP code: $AUTH_CODE (expected 200)"
        add_test_result "Exercise 4: Protected With Auth" "fail" "Expected HTTP 200, got $AUTH_CODE" "HTTP $AUTH_CODE"
    fi
else
    log_warn "Skipping - no token available from Exercise 3"
    add_test_result "Exercise 4: Protected With Auth" "fail" "Skipped - no token from previous exercise"
fi
echo ""

# Exercise 5: Token Concept
echo "Exercise 5: Understanding JWT token structure..."

if [ -n "$TOKEN" ]; then
    log_info "Analyzing token structure"

    # Count dots (JWT has 2 dots, creating 3 parts: header.payload.signature)
    DOT_COUNT=$(echo "$TOKEN" | grep -o '\.' | wc -l | tr -d ' ')

    if [ "$DOT_COUNT" = "2" ]; then
        log_info "Token structure: header.payload.signature (valid JWT format)"
        log_info "JWT tokens are self-contained and stateless"
        log_info "They include expiration time (exp claim) for automatic invalidation"
        add_test_result "Exercise 5: Token Concept" "pass" "Token has correct JWT structure (3 parts)" "Dots: $DOT_COUNT, Format: header.payload.signature"
    else
        log_warn "Token doesn't follow standard JWT format (has $DOT_COUNT dots, expected 2)"
        add_test_result "Exercise 5: Token Concept" "pass" "Token received but format non-standard" "Dots: $DOT_COUNT"
    fi
else
    log_warn "No token to analyze"
    add_test_result "Exercise 5: Token Concept" "fail" "No token available for analysis"
fi
echo ""

# Output results
echo "========================================="
echo "Exercise Results (JSON)"
echo "========================================="
output_results "$LAB_NAME"
echo ""

# Save results to file
save_results "$LAB_NAME"
