import pytest
from fastapi.testclient import TestClient
from unittest.mock import Mock, patch
from app.main import app

client = TestClient(app)

# Mock Redis for testing
@pytest.fixture
def mock_redis():
    with patch('app.main.redis_client') as mock:
        mock.ping.return_value = True
        mock.exists.return_value = False
        mock.get.return_value = None
        mock.set.return_value = True
        mock.hset.return_value = True
        mock.hgetall.return_value = {}
        mock.hincrby.return_value = 1
        mock.time.return_value = (1234567890, 0)
        yield mock

def test_read_root():
    """Test the health check endpoint."""
    response = client.get("/")
    assert response.status_code == 200
    data = response.json()
    assert "message" in data
    assert "version" in data
    assert "redis_connected" in data

def test_health_check():
    """Test the detailed health check endpoint."""
    response = client.get("/health")
    assert response.status_code in [200, 503]  # Depends on Redis connection

def test_shorten_url_success(mock_redis):
    """Test successful URL shortening."""
    mock_redis.exists.return_value = False  # Short code doesn't exist
    
    response = client.post("/shorten", json={
        "url": "https://example.com/very/long/path"
    })
    
    assert response.status_code == 200
    data = response.json()
    assert "short_url" in data
    assert "original_url" in data
    assert "short_code" in data
    assert data["original_url"] == "https://example.com/very/long/path"
    assert len(data["short_code"]) == 6

def test_shorten_url_with_custom_code(mock_redis):
    """Test URL shortening with custom code."""
    mock_redis.exists.return_value = False  # Custom code doesn't exist
    
    response = client.post("/shorten", json={
        "url": "https://example.com/test",
        "custom_code": "mycode"
    })
    
    assert response.status_code == 200
    data = response.json()
    assert data["short_code"] == "mycode"

def test_shorten_url_custom_code_exists(mock_redis):
    """Test URL shortening with existing custom code."""
    mock_redis.exists.return_value = True  # Custom code already exists
    
    response = client.post("/shorten", json={
        "url": "https://example.com/test",
        "custom_code": "existing"
    })
    
    assert response.status_code == 409
    assert "already exists" in response.json()["detail"]

def test_shorten_url_invalid_custom_code(mock_redis):
    """Test URL shortening with invalid custom code."""
    response = client.post("/shorten", json={
        "url": "https://example.com/test",
        "custom_code": "ab"  # Too short
    })
    
    assert response.status_code == 400
    assert "3-20 alphanumeric characters" in response.json()["detail"]

def test_shorten_url_invalid_url():
    """Test URL shortening with invalid URL."""
    response = client.post("/shorten", json={
        "url": "not-a-valid-url"
    })
    
    assert response.status_code == 422  # Validation error

def test_redirect_success(mock_redis):
    """Test successful URL redirect."""
    mock_redis.get.return_value = "https://example.com/original"
    
    response = client.get("/abc123", follow_redirects=False)
    
    assert response.status_code == 301
    assert response.headers["location"] == "https://example.com/original"

def test_redirect_not_found(mock_redis):
    """Test redirect with non-existent short code."""
    mock_redis.get.return_value = None
    
    response = client.get("/nonexistent")
    
    assert response.status_code == 404
    assert "not found" in response.json()["detail"]

def test_redirect_invalid_format():
    """Test redirect with invalid short code format."""
    response = client.get("/ab")  # Too short
    
    assert response.status_code == 400
    assert "Invalid short code format" in response.json()["detail"]

def test_get_stats_success(mock_redis):
    """Test getting URL statistics."""
    mock_redis.hgetall.return_value = {
        "original_url": "https://example.com/test",
        "created_at": "1234567890",
        "clicks": "5"
    }
    
    response = client.get("/stats/abc123")
    
    assert response.status_code == 200
    data = response.json()
    assert data["short_code"] == "abc123"
    assert data["original_url"] == "https://example.com/test"
    assert data["clicks"] == 5

def test_get_stats_not_found(mock_redis):
    """Test getting stats for non-existent short code."""
    mock_redis.hgetall.return_value = {}
    
    response = client.get("/stats/nonexistent")
    
    assert response.status_code == 404
    assert "not found" in response.json()["detail"]

def test_redis_connection_error():
    """Test behavior when Redis is not available."""
    with patch('app.main.redis_client', None):
        response = client.post("/shorten", json={
            "url": "https://example.com/test"
        })
        
        assert response.status_code == 503
        assert "Redis connection not available" in response.json()["detail"] 