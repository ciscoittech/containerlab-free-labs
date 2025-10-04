"""
Zero Trust Web Application (Simplified POC)
Demonstrates token-based access control
"""
from fastapi import FastAPI, HTTPException, Header
import httpx
import logging

logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)

app = FastAPI(title="Zero Trust Web App", version="1.0.0-POC")

IDENTITY_SERVICE = "http://identity:8443"

@app.get("/")
async def public_homepage():
    """Public endpoint - no authentication required"""
    return {
        "service": "zero-trust-web",
        "message": "Welcome! This is a public endpoint.",
        "endpoints": {
            "public": "/",
            "protected": "/api/profile (requires Bearer token)",
            "login": "POST to identity:8443/auth/login"
        }
    }

@app.get("/api/profile")
async def get_profile(authorization: str = Header(None)):
    """
    Protected endpoint - requires valid JWT token

    Zero Trust: Verify explicitly on every request
    """
    if not authorization or not authorization.startswith("Bearer "):
        raise HTTPException(
            status_code=401,
            detail="Missing or invalid authorization header. Use: Authorization: Bearer <token>"
        )

    token = authorization.replace("Bearer ", "")

    # Validate token with Identity service
    async with httpx.AsyncClient() as client:
        try:
            response = await client.post(
                f"{IDENTITY_SERVICE}/auth/validate",
                json={"token": token},
                timeout=5.0
            )

            if response.status_code != 200:
                raise HTTPException(status_code=401, detail="Invalid or expired token")

            token_data = response.json()

            return {
                "message": "Access granted! Token is valid.",
                "user": {
                    "user_id": token_data["user_id"],
                    "username": token_data["username"],
                    "role": token_data["role"]
                },
                "zero_trust_principle": "Verify explicitly - token validated on every request"
            }

        except httpx.RequestError as e:
            logger.error(f"Error connecting to Identity service: {e}")
            raise HTTPException(status_code=503, detail="Identity service unavailable")

@app.get("/health")
async def health():
    """Health check"""
    return {"service": "web", "status": "healthy"}

if __name__ == "__main__":
    import uvicorn
    uvicorn.run(app, host="0.0.0.0", port=8080)
