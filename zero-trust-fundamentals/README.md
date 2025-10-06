# Zero Trust Fundamentals - Proof of Concept

[![Open in GitHub Codespaces](../.github/images/open-in-codespaces.svg)](https://codespaces.new/ciscoittech/containerlab-free-labs?devcontainer_path=zero-trust-fundamentals/.devcontainer/devcontainer.json&quickstart=1)

**Status:** 🚧 POC - Simplified demonstration of core Zero Trust principles

## Overview

This lab demonstrates the fundamental principles of Zero Trust security using a minimal microservices architecture. Learn how modern applications implement "never trust, always verify" with practical, hands-on examples.

### What You'll Learn

✅ **Verify Explicitly** - Every request authenticated, not just login
✅ **Least Privilege** - Minimum required access (public vs protected endpoints)
✅ **Assume Breach** - Short-lived tokens (5 minutes), continuous validation

## Architecture (POC)

```
External User
      ↓
  [Identity Service] :8443
      ↓ (validates)
  [Web Application] :8080
      ↓ (stores)
   [MongoDB] :27017
```

### Services

| Service | Port | Purpose |
|---------|------|---------|
| **Identity** | 8443 | Authentication, JWT token generation |
| **Web App** | 8080 | Protected API with token validation |
| **MongoDB** | 27017 | User data, sessions, audit logs |

## Quick Start (5 minutes)

### Prerequisites

- Docker & Docker Compose installed
- curl (for testing)
- python3 (for JSON formatting)

### Run the Demo

```bash
cd zero-trust-fundamentals

# Start all services
docker-compose up -d

# Wait 30 seconds for services to initialize
sleep 30

# Run automated demo
./scripts/demo.sh
```

The demo script will:
1. ✅ Start all services
2. ✅ Test public endpoint (no auth required)
3. ❌ Try protected endpoint without token (fails)
4. ✅ Login and get JWT token
5. ✅ Access protected endpoint with token (succeeds)
6. 📚 Explain token expiry (5 minutes)

## Manual Testing

### 1. Access Public Endpoint (No Auth)

```bash
curl http://localhost:8080/
```

**Response:**
```json
{
  "service": "zero-trust-web",
  "message": "Welcome! This is a public endpoint.",
  "endpoints": {
    "public": "/",
    "protected": "/api/profile (requires Bearer token)"
  }
}
```

### 2. Try Protected Endpoint Without Token

```bash
curl http://localhost:8080/api/profile
```

**Response:** `401 Unauthorized` ❌

### 3. Login to Get Token

```bash
curl -X POST http://localhost:8443/auth/login \
  -H "Content-Type: application/json" \
  -d '{"username": "alice", "password": "password123"}'
```

**Response:**
```json
{
  "access_token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
  "token_type": "Bearer",
  "expires_in": 300,
  "user_id": "user-001"
}
```

**Copy the `access_token` value!**

### 4. Access Protected Endpoint With Token

```bash
TOKEN="<paste token here>"

curl http://localhost:8080/api/profile \
  -H "Authorization: Bearer $TOKEN"
```

**Response:**
```json
{
  "message": "Access granted! Token is valid.",
  "user": {
    "user_id": "user-001",
    "username": "alice",
    "role": "user"
  },
  "zero_trust_principle": "Verify explicitly - token validated on every request"
}
```

✅ **Success!**

### 5. Test Token Expiry

Wait 5 minutes, then try again with the same token:

```bash
curl http://localhost:8080/api/profile \
  -H "Authorization: Bearer $TOKEN"
```

**Response:** `401 Token expired` ❌

**Zero Trust Principle:** Short-lived credentials reduce risk if compromised.

## Zero Trust Principles Demonstrated

### 1. Verify Explicitly

**Traditional security:** Log in once, trusted inside network
**Zero Trust:** Every API request validates token with Identity service

**Code example (web/main.py):**
```python
@app.get("/api/profile")
async def get_profile(authorization: str = Header(None)):
    # Validate token on EVERY request
    response = await client.post(
        f"{IDENTITY_SERVICE}/auth/validate",
        json={"token": token}
    )
```

### 2. Least Privilege

**Public endpoint:** `/` - No authentication
**Protected endpoint:** `/api/profile` - Requires valid token

Users only get access to what they need, when they need it.

### 3. Assume Breach

**Short-lived tokens:** 5 minutes (not hours/days)
**Why:** If attacker steals token, limited time to exploit
**Session tracking:** Tokens can be revoked immediately

## Default Users

| Username | Password | Role |
|----------|----------|------|
| alice | password123 | user |
| bob | password123 | admin |

## API Documentation

### Identity Service (Port 8443)

**Login:**
```bash
POST /auth/login
{
  "username": "alice",
  "password": "password123",
  "device_id": "laptop-001"  # optional
}
```

**Validate Token:**
```bash
POST /auth/validate
{
  "token": "eyJhbGci..."
}
```

**Logout:**
```bash
POST /auth/logout
Authorization: Bearer <token>
```

**Health Check:**
```bash
GET /health
```

**Metrics:**
```bash
GET /metrics
```

### Web Application (Port 8080)

**Public Homepage:**
```bash
GET /
```

**Protected Profile:**
```bash
GET /api/profile
Authorization: Bearer <token>
```

**Health Check:**
```bash
GET /health
```

## Troubleshooting

### Services won't start

```bash
# Check logs
docker-compose logs

# Restart services
docker-compose down
docker-compose up -d
```

### Can't connect to services

```bash
# Verify services running
docker-compose ps

# Check ports not in use
lsof -i :8443
lsof -i :8080
```

### Token validation fails

- Check token hasn't expired (5 minute limit)
- Verify `Authorization: Bearer <token>` header format
- Try getting fresh token with `/auth/login`

## Cleanup

```bash
docker-compose down -v  # -v removes volumes (MongoDB data)
```

## What's Next? (Full Lab Coming Soon)

This POC demonstrates core concepts. The full lab will add:

🔜 **SIEM Integration** - Centralized security logging
🔜 **VyOS Firewall** - Network-level zero trust
🔜 **Containerlab Topology** - Complete network simulation
🔜 **Automated Tests** - 8 validation tests
🔜 **Device Health Checks** - Verify device compliance
🔜 **Risk-Based Access** - Adaptive authentication

## Learning Resources

- **Zero Trust Model:** [NIST SP 800-207](https://csrc.nist.gov/publications/detail/sp/800-207/final)
- **JWT Best Practices:** [RFC 8725](https://datatracker.ietf.org/doc/html/rfc8725)
- **FastAPI Security:** [FastAPI Docs](https://fastapi.tiangolo.com/tutorial/security/)

## Contributing

This is a free educational lab. Contributions welcome!

- Report issues: GitHub Issues
- Suggest improvements: Pull Requests
- Share feedback: Discussions

## License

MIT License - Free to use for learning and teaching

---

**Built with:** FastAPI • MongoDB • Docker • Zero Trust principles

**Part of:** Free Containerlab Security Labs series
