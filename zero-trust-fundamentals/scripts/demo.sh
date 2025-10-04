#!/bin/bash
# Zero Trust Fundamentals - Proof of Concept Demo

set -e

GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

echo "======================================"
echo "Zero Trust Fundamentals - POC Demo"
echo "======================================"
echo ""

# Start services
echo -e "${YELLOW}Step 1: Starting services...${NC}"
docker-compose up -d
echo "Waiting for services to be ready (30 seconds)..."
sleep 30

# Check health
echo -e "\n${YELLOW}Step 2: Health checks...${NC}"
echo "Identity service:"
curl -s http://localhost:8443/health | python3 -m json.tool || echo "Service not ready"

echo -e "\nWeb service:"
curl -s http://localhost:8080/health | python3 -m json.tool || echo "Service not ready"

# Test 1: Public access (no auth)
echo -e "\n${YELLOW}Step 3: Test public endpoint (no authentication)${NC}"
echo "GET http://localhost:8080/"
curl -s http://localhost:8080/ | python3 -m json.tool

# Test 2: Try protected endpoint without token (should fail)
echo -e "\n${YELLOW}Step 4: Try protected endpoint WITHOUT token (should fail)${NC}"
echo "GET http://localhost:8080/api/profile"
HTTP_CODE=$(curl -s -o /dev/null -w "%{http_code}" http://localhost:8080/api/profile)
if [ "$HTTP_CODE" == "401" ]; then
    echo -e "${GREEN}✓ PASS: Correctly rejected (401 Unauthorized)${NC}"
else
    echo -e "${RED}✗ FAIL: Got HTTP $HTTP_CODE (expected 401)${NC}"
fi

# Test 3: Login and get token
echo -e "\n${YELLOW}Step 5: Login to get JWT token${NC}"
echo "POST http://localhost:8443/auth/login"
echo "Username: alice, Password: password123"

TOKEN_RESPONSE=$(curl -s -X POST http://localhost:8443/auth/login \
  -H "Content-Type: application/json" \
  -d '{"username": "alice", "password": "password123"}')

echo "$TOKEN_RESPONSE" | python3 -m json.tool

TOKEN=$(echo "$TOKEN_RESPONSE" | python3 -c "import sys, json; print(json.load(sys.stdin)['access_token'])" 2>/dev/null || echo "")

if [ -z "$TOKEN" ]; then
    echo -e "${RED}✗ Failed to get token${NC}"
    exit 1
fi

echo -e "${GREEN}✓ Got token (expires in 5 minutes)${NC}"

# Test 4: Access protected endpoint WITH token (should succeed)
echo -e "\n${YELLOW}Step 6: Access protected endpoint WITH valid token${NC}"
echo "GET http://localhost:8080/api/profile"
echo "Authorization: Bearer <token>"

PROFILE_RESPONSE=$(curl -s http://localhost:8080/api/profile \
  -H "Authorization: Bearer $TOKEN")

echo "$PROFILE_RESPONSE" | python3 -m json.tool

if echo "$PROFILE_RESPONSE" | grep -q "Access granted"; then
    echo -e "${GREEN}✓ PASS: Token validated, access granted${NC}"
else
    echo -e "${RED}✗ FAIL: Token validation failed${NC}"
fi

# Test 5: Wait for token expiry
echo -e "\n${YELLOW}Step 7: Token expiry demonstration${NC}"
echo "Tokens expire in 5 minutes (Zero Trust: short-lived credentials)"
echo "To test expiry, wait 5 minutes and run:"
echo "  curl -H \"Authorization: Bearer \$TOKEN\" http://localhost:8080/api/profile"
echo ""
echo "Expected: 401 Unauthorized (token expired)"

# Summary
echo -e "\n${GREEN}======================================"
echo "POC Demo Complete!"
echo "======================================${NC}"
echo ""
echo "Zero Trust Principles Demonstrated:"
echo "1. ✓ Verify explicitly - Every request validates token"
echo "2. ✓ Least privilege - Public endpoint vs protected"
echo "3. ✓ Assume breach - Short-lived tokens (5 min)"
echo ""
echo "Services running:"
echo "  - Identity: http://localhost:8443"
echo "  - Web App:  http://localhost:8080"
echo "  - MongoDB:  localhost:27017 (internal)"
echo ""
echo "Credentials:"
echo "  - alice / password123 (user role)"
echo "  - bob / password123 (admin role)"
echo ""
echo "Next steps:"
echo "  - docker-compose logs -f         # View logs"
echo "  - docker-compose down            # Stop services"
echo "  - ./scripts/validate.sh          # Run full test suite (coming soon)"
echo ""
