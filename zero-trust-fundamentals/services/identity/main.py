"""
Zero Trust Identity Service
Handles authentication, JWT token generation, and token validation
"""
from fastapi import FastAPI, HTTPException, Depends, Header
from fastapi.middleware.cors import CORSMiddleware
from pydantic import BaseModel
from datetime import datetime, timedelta
from typing import Optional
import jwt
import hashlib
import logging
from motor.motor_asyncio import AsyncIOMotorClient
import os

# Configure logging
logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)

app = FastAPI(title="Zero Trust Identity Service", version="1.0.0")

# CORS configuration
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# Configuration
SECRET_KEY = os.getenv("JWT_SECRET_KEY", "your-secret-key-change-in-production")
ALGORITHM = "HS256"
TOKEN_EXPIRE_MINUTES = 5  # Short-lived tokens (Zero Trust principle)
MONGO_URL = os.getenv("MONGO_URL", "mongodb://mongodb:27017")

# MongoDB client
mongo_client = AsyncIOMotorClient(MONGO_URL)
db = mongo_client.zero_trust
users_collection = db.users
sessions_collection = db.sessions
audit_log_collection = db.audit_logs

# Models
class LoginRequest(BaseModel):
    username: str
    password: str
    device_id: Optional[str] = "unknown"

class TokenResponse(BaseModel):
    access_token: str
    token_type: str
    expires_in: int
    user_id: str

class TokenValidationRequest(BaseModel):
    token: str

class User(BaseModel):
    user_id: str
    username: str
    email: str
    role: str
    active: bool

# Helper functions
def hash_password(password: str) -> str:
    """Simple password hashing (use bcrypt in production)"""
    return hashlib.sha256(password.encode()).hexdigest()

def create_jwt_token(user_id: str, username: str, role: str) -> dict:
    """Create JWT token with short expiration"""
    expiry = datetime.utcnow() + timedelta(minutes=TOKEN_EXPIRE_MINUTES)

    payload = {
        "sub": user_id,
        "username": username,
        "role": role,
        "exp": expiry,
        "iat": datetime.utcnow()
    }

    token = jwt.encode(payload, SECRET_KEY, algorithm=ALGORITHM)

    return {
        "token": token,
        "expires_at": expiry,
        "expires_in": TOKEN_EXPIRE_MINUTES * 60
    }

def verify_jwt_token(token: str) -> dict:
    """Verify and decode JWT token"""
    try:
        payload = jwt.decode(token, SECRET_KEY, algorithms=[ALGORITHM])
        return payload
    except jwt.ExpiredSignatureError:
        raise HTTPException(status_code=401, detail="Token expired")
    except jwt.InvalidTokenError:
        raise HTTPException(status_code=401, detail="Invalid token")

async def log_audit_event(event_type: str, user_id: str, details: dict):
    """Log security events to audit log"""
    await audit_log_collection.insert_one({
        "timestamp": datetime.utcnow(),
        "event_type": event_type,
        "user_id": user_id,
        "details": details
    })

    # Also send to SIEM
    logger.info(f"AUDIT: {event_type} - User: {user_id} - {details}")

# Startup: Initialize default users
@app.on_event("startup")
async def startup_event():
    """Initialize database with default users"""
    logger.info("Starting Identity Service...")

    # Create default users if not exist
    alice = await users_collection.find_one({"username": "alice"})
    if not alice:
        await users_collection.insert_many([
            {
                "user_id": "user-001",
                "username": "alice",
                "password_hash": hash_password("password123"),
                "email": "alice@example.com",
                "role": "user",
                "active": True
            },
            {
                "user_id": "user-002",
                "username": "bob",
                "password_hash": hash_password("password123"),
                "email": "bob@example.com",
                "role": "admin",
                "active": True
            }
        ])
        logger.info("Default users created: alice (user), bob (admin)")

# Health check
@app.get("/health")
async def health_check():
    """Service health check"""
    return {
        "service": "identity",
        "status": "healthy",
        "timestamp": datetime.utcnow().isoformat(),
        "token_expiry_minutes": TOKEN_EXPIRE_MINUTES
    }

# Authentication endpoints
@app.post("/auth/login", response_model=TokenResponse)
async def login(request: LoginRequest):
    """
    Authenticate user and return JWT token

    Zero Trust Principle: Verify explicitly
    """
    # Find user
    user = await users_collection.find_one({"username": request.username})

    if not user:
        await log_audit_event("login_failed", "unknown", {
            "username": request.username,
            "reason": "user_not_found"
        })
        raise HTTPException(status_code=401, detail="Invalid credentials")

    # Verify password
    password_hash = hash_password(request.password)
    if user["password_hash"] != password_hash:
        await log_audit_event("login_failed", user["user_id"], {
            "username": request.username,
            "reason": "invalid_password"
        })
        raise HTTPException(status_code=401, detail="Invalid credentials")

    # Check if user is active
    if not user.get("active", False):
        await log_audit_event("login_failed", user["user_id"], {
            "username": request.username,
            "reason": "account_disabled"
        })
        raise HTTPException(status_code=403, detail="Account disabled")

    # Create JWT token
    token_data = create_jwt_token(
        user_id=user["user_id"],
        username=user["username"],
        role=user["role"]
    )

    # Store session
    await sessions_collection.insert_one({
        "user_id": user["user_id"],
        "token_hash": hashlib.sha256(token_data["token"].encode()).hexdigest(),
        "created_at": datetime.utcnow(),
        "expires_at": token_data["expires_at"],
        "device_id": request.device_id,
        "active": True
    })

    # Log successful login
    await log_audit_event("login_success", user["user_id"], {
        "username": request.username,
        "device_id": request.device_id,
        "token_expires_in": token_data["expires_in"]
    })

    return TokenResponse(
        access_token=token_data["token"],
        token_type="Bearer",
        expires_in=token_data["expires_in"],
        user_id=user["user_id"]
    )

@app.post("/auth/validate")
async def validate_token(request: TokenValidationRequest):
    """
    Validate JWT token

    Zero Trust Principle: Continuous verification
    """
    try:
        # Verify token
        payload = verify_jwt_token(request.token)

        # Check if session still active in database
        token_hash = hashlib.sha256(request.token.encode()).hexdigest()
        session = await sessions_collection.find_one({
            "token_hash": token_hash,
            "active": True
        })

        if not session:
            await log_audit_event("token_validation_failed", payload.get("sub", "unknown"), {
                "reason": "session_not_found_or_revoked"
            })
            raise HTTPException(status_code=401, detail="Session not found or revoked")

        # Check if user still active
        user = await users_collection.find_one({"user_id": payload["sub"]})
        if not user or not user.get("active", False):
            await log_audit_event("token_validation_failed", payload.get("sub", "unknown"), {
                "reason": "user_inactive"
            })
            raise HTTPException(status_code=403, detail="User account disabled")

        await log_audit_event("token_validation_success", payload["sub"], {
            "username": payload["username"]
        })

        return {
            "valid": True,
            "user_id": payload["sub"],
            "username": payload["username"],
            "role": payload["role"],
            "expires_at": payload["exp"]
        }

    except HTTPException:
        raise
    except Exception as e:
        logger.error(f"Token validation error: {str(e)}")
        raise HTTPException(status_code=401, detail="Invalid token")

@app.post("/auth/logout")
async def logout(authorization: str = Header(None)):
    """
    Revoke token/session

    Zero Trust Principle: Explicit session termination
    """
    if not authorization or not authorization.startswith("Bearer "):
        raise HTTPException(status_code=401, detail="Missing or invalid authorization header")

    token = authorization.replace("Bearer ", "")

    try:
        payload = verify_jwt_token(token)
        token_hash = hashlib.sha256(token.encode()).hexdigest()

        # Revoke session
        await sessions_collection.update_one(
            {"token_hash": token_hash},
            {"$set": {"active": False, "revoked_at": datetime.utcnow()}}
        )

        await log_audit_event("logout", payload["sub"], {
            "username": payload["username"]
        })

        return {"message": "Logged out successfully"}

    except HTTPException:
        raise
    except Exception as e:
        logger.error(f"Logout error: {str(e)}")
        raise HTTPException(status_code=500, detail="Logout failed")

@app.get("/users/me")
async def get_current_user(authorization: str = Header(None)):
    """
    Get current authenticated user details
    Requires valid token
    """
    if not authorization or not authorization.startswith("Bearer "):
        raise HTTPException(status_code=401, detail="Missing authorization header")

    token = authorization.replace("Bearer ", "")
    payload = verify_jwt_token(token)

    user = await users_collection.find_one({"user_id": payload["sub"]})
    if not user:
        raise HTTPException(status_code=404, detail="User not found")

    return {
        "user_id": user["user_id"],
        "username": user["username"],
        "email": user["email"],
        "role": user["role"],
        "active": user["active"]
    }

@app.get("/metrics")
async def get_metrics():
    """Service metrics for monitoring"""
    total_users = await users_collection.count_documents({})
    active_sessions = await sessions_collection.count_documents({"active": True})
    total_logins = await audit_log_collection.count_documents({"event_type": "login_success"})
    failed_logins = await audit_log_collection.count_documents({"event_type": "login_failed"})

    return {
        "total_users": total_users,
        "active_sessions": active_sessions,
        "total_logins_today": total_logins,
        "failed_logins_today": failed_logins,
        "token_expiry_minutes": TOKEN_EXPIRE_MINUTES
    }

if __name__ == "__main__":
    import uvicorn
    uvicorn.run(app, host="0.0.0.0", port=8443)
