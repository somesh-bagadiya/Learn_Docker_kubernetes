import os
import string
import random
from typing import Optional
from fastapi import FastAPI, HTTPException, Response
from fastapi.middleware.cors import CORSMiddleware
from fastapi.responses import RedirectResponse
from pydantic import BaseModel, HttpUrl
import redis
from redis.exceptions import ConnectionError as RedisConnectionError

# Initialize FastAPI app
app = FastAPI(
    title="Shortly URL Shortener",
    description="A simple URL shortener built with FastAPI and Redis",
    version="1.0.0"
)

# Add CORS middleware for frontend integration
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],  # In production, specify actual frontend URLs
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# Redis connection
REDIS_HOST = os.getenv("REDIS_HOST", "localhost")
REDIS_PORT = int(os.getenv("REDIS_PORT", 6379))
REDIS_DB = int(os.getenv("REDIS_DB", 0))

try:
    redis_client = redis.Redis(host=REDIS_HOST, port=REDIS_PORT, db=REDIS_DB, decode_responses=True)
    # Test connection
    redis_client.ping()
    print(f"✅ Connected to Redis at {REDIS_HOST}:{REDIS_PORT}")
except RedisConnectionError:
    print(f"❌ Failed to connect to Redis at {REDIS_HOST}:{REDIS_PORT}")
    redis_client = None

# Pydantic models for request/response
class URLRequest(BaseModel):
    url: HttpUrl
    custom_code: Optional[str] = None

class URLResponse(BaseModel):
    short_url: str
    original_url: str
    short_code: str

# Utility functions
def generate_short_code(length: int = 6) -> str:
    """Generate a random short code using alphanumeric characters."""
    characters = string.ascii_letters + string.digits
    return ''.join(random.choice(characters) for _ in range(length))

def is_valid_custom_code(code: str) -> bool:
    """Validate custom short code (alphanumeric, 3-20 chars)."""
    return (
        3 <= len(code) <= 20 and
        code.isalnum() and
        not code.isdigit()  # Prevent purely numeric codes
    )

# API Endpoints
@app.get("/")
def read_root():
    """Health check endpoint."""
    return {
        "message": "Shortly Backend is running!",
        "version": "1.0.0",
        "redis_connected": redis_client is not None
    }

@app.post("/shorten", response_model=URLResponse)
def shorten_url(request: URLRequest):
    """Create a shortened URL."""
    if not redis_client:
        raise HTTPException(status_code=503, detail="Redis connection not available")
    
    original_url = str(request.url)
    
    # Handle custom short code
    if request.custom_code:
        if not is_valid_custom_code(request.custom_code):
            raise HTTPException(
                status_code=400, 
                detail="Custom code must be 3-20 alphanumeric characters and not purely numeric"
            )
        
        short_code = request.custom_code
        
        # Check if custom code already exists
        if redis_client.exists(short_code):
            raise HTTPException(status_code=409, detail="Custom code already exists")
    else:
        # Generate random short code
        max_attempts = 10
        for _ in range(max_attempts):
            short_code = generate_short_code()
            if not redis_client.exists(short_code):
                break
        else:
            raise HTTPException(status_code=500, detail="Unable to generate unique short code")
    
    # Store in Redis
    try:
        redis_client.set(short_code, original_url)
        # Also store reverse mapping for potential analytics
        redis_client.hset(f"url:{short_code}", mapping={
            "original_url": original_url,
            "created_at": str(redis_client.time()[0]),  # Unix timestamp
            "clicks": 0
        })
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Failed to store URL: {str(e)}")
    
    # Construct short URL (in production, use actual domain)
    base_url = os.getenv("BASE_URL", "http://localhost:8000")
    short_url = f"{base_url}/{short_code}"
    
    return URLResponse(
        short_url=short_url,
        original_url=original_url,
        short_code=short_code
    )

@app.get("/{short_code}")
def redirect_to_url(short_code: str):
    """Redirect to the original URL using the short code."""
    if not redis_client:
        raise HTTPException(status_code=503, detail="Redis connection not available")
    
    # Validate short code format
    if not short_code.isalnum() or len(short_code) < 3:
        raise HTTPException(status_code=400, detail="Invalid short code format")
    
    # Get original URL from Redis
    try:
        original_url = redis_client.get(short_code)
        if not original_url:
            raise HTTPException(status_code=404, detail="Short code not found")
        
        # Increment click counter
        redis_client.hincrby(f"url:{short_code}", "clicks", 1)
        
        # Redirect to original URL
        return RedirectResponse(url=original_url, status_code=301)
        
    except Exception as e:
        if "not found" in str(e):
            raise
        raise HTTPException(status_code=500, detail=f"Failed to retrieve URL: {str(e)}")

@app.get("/stats/{short_code}")
def get_url_stats(short_code: str):
    """Get statistics for a shortened URL."""
    if not redis_client:
        raise HTTPException(status_code=503, detail="Redis connection not available")
    
    try:
        stats = redis_client.hgetall(f"url:{short_code}")
        if not stats:
            raise HTTPException(status_code=404, detail="Short code not found")
        
        return {
            "short_code": short_code,
            "original_url": stats.get("original_url"),
            "created_at": int(stats.get("created_at", 0)),
            "clicks": int(stats.get("clicks", 0))
        }
    except Exception as e:
        if "not found" in str(e):
            raise
        raise HTTPException(status_code=500, detail=f"Failed to retrieve stats: {str(e)}")

# Health check endpoint for container orchestration
@app.get("/health")
def health_check():
    """Detailed health check for monitoring systems."""
    redis_status = "healthy" if redis_client else "unhealthy"
    
    health_data = {
        "status": "healthy" if redis_client else "unhealthy",
        "redis": redis_status,
        "version": "1.0.0"
    }
    
    if redis_client:
        try:
            redis_client.ping()
            health_data["redis_ping"] = "ok"
        except:
            health_data["redis_ping"] = "failed"
            health_data["status"] = "unhealthy"
    
    status_code = 200 if health_data["status"] == "healthy" else 503
    return Response(
        content=str(health_data),
        status_code=status_code,
        media_type="application/json"
    ) 