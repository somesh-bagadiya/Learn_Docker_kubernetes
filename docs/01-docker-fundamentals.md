# 🐳 Docker Fundamentals: Building Production-Ready Containers

**Module 01: Containerization Mastery**

---

## 📍 Navigation

**Current Location:** `/Learn_Docker_kubernetes/docs/01-docker-fundamentals.md`
**Project Files:** `/Learn_Docker_kubernetes/shortly/`

---

## 🎯 Learning Objectives

By the end of this module, you will:

- **Understand containerization** concepts and why they matter
- **Build a FastAPI backend** for the Shortly URL shortener
- **Write comprehensive tests** using pytest
- **Create multi-stage Dockerfiles** following security best practices
- **Run containers locally** and verify functionality
- **Orchestrate multi-service apps** with Docker Compose

---

## 📋 Prerequisites

Before starting this module, ensure you have:

- **Docker Desktop** installed and running
- **Python 3.11+** installed locally (for testing)
- **Git** for version control
- **Text editor** (VS Code recommended)
- **Terminal/Command Prompt** access

**Verify installations:**
```bash
# Check Docker
docker --version
docker-compose --version

# Check Python
python --version
pip --version
```

---

## 💡 What is Containerization?

### **The Problem**
Traditional applications face the "it works on my machine" problem:
- Different operating systems
- Conflicting dependencies
- Environment inconsistencies
- Complex deployment processes

### **The Solution: Containers**
A container packages your application with:
- **Application code**
- **Runtime dependencies** 
- **System libraries**
- **Environment configuration**

**Key Benefits:**
- **Consistency** across development, testing, and production
- **Isolation** from host system and other applications
- **Portability** across different environments
- **Scalability** for handling increased load
- **Efficiency** compared to virtual machines

### **Docker vs Virtual Machines**
```
Virtual Machines          vs          Containers
┌─────────────────────┐              ┌─────────────────────┐
│     Application     │              │     Application     │
│                     │              │                     │
│   Guest OS (Full)   │              │   Container Runtime │
│                     │              │                     │
│    Hypervisor       │              │    Docker Engine    │
│                     │              │                     │
│      Host OS        │              │      Host OS        │
└─────────────────────┘              └─────────────────────┘
  Heavy, Slow, Isolated               Light, Fast, Efficient
```

---

## 🚀 Project 1: Building the Shortly Backend API

### **What We're Building**

A FastAPI-based URL shortener with these features:
- **POST /shorten** - Create short URLs
- **GET /{short_code}** - Redirect to original URLs
- **GET /stats/{short_code}** - Get click statistics
- **GET /health** - Health check for monitoring
- **Redis integration** for data storage
- **Comprehensive testing** with pytest

### **Architecture Overview**
```
┌─────────────────┐    HTTP     ┌─────────────────┐    TCP     ┌─────────────────┐
│   Client/User   │ ──────────► │  FastAPI App    │ ─────────► │   Redis DB      │
│                 │             │  (Port 8000)    │            │  (Port 6379)    │
└─────────────────┘             └─────────────────┘            └─────────────────┘
```

---

## ⚡ Step 1: Project Structure Setup

**Working Directory:** `/Learn_Docker_kubernetes/shortly/backend/`

Our backend structure follows Python best practices:
```
/Learn_Docker_kubernetes/shortly/backend/
├── app/
│   └── main.py              # FastAPI application
├── tests/
│   └── test_main.py         # Pytest test suite
├── Dockerfile               # Container definition
└── requirements.txt         # Python dependencies
```

**Verify current structure:**
```bash
# Navigate to project root
cd /Learn_Docker_kubernetes/shortly/backend

# List current files
ls -la
```

**Expected output:**
```
app/
tests/
Dockerfile
requirements.txt
```

---

## ⚡ Step 2: Understanding the FastAPI Application

**File Location:** `/Learn_Docker_kubernetes/shortly/backend/app/main.py`

### **Key Components Explained**

**1. FastAPI Application Setup:**
```python
from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware

app = FastAPI(
    title="Shortly URL Shortener",
    description="A simple URL shortener built with FastAPI and Redis",
    version="1.0.0"
)
```

**2. CORS Middleware for Frontend Integration:**
```python
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],  # In production, specify actual frontend URLs
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)
```

**3. Redis Connection with Environment Variables:**
```python
REDIS_HOST = os.getenv("REDIS_HOST", "localhost")
REDIS_PORT = int(os.getenv("REDIS_PORT", 6379))
```

**4. API Endpoints:**
- `GET /` - Health check
- `POST /shorten` - Create short URLs
- `GET /{short_code}` - Redirect to original URL
- `GET /stats/{short_code}` - Get click statistics
- `GET /health` - Detailed health check

### **Enterprise-Grade Features**
- **Environment-based configuration** for different deployment environments
- **Comprehensive error handling** with proper HTTP status codes
- **Input validation** using Pydantic models
- **Health checks** for container orchestration
- **CORS configuration** for frontend integration
- **Logging and monitoring** readiness

---

## ⚡ Step 3: Understanding the Test Suite

**File Location:** `/Learn_Docker_kubernetes/shortly/backend/tests/test_main.py`

### **Testing Strategy**

Our test suite covers:
- **Unit tests** for individual endpoints
- **Integration tests** for Redis connectivity
- **Error handling** tests for edge cases
- **Mocking** for isolated testing

**Key Test Categories:**
```python
def test_read_root():           # Health check endpoint
def test_shorten_url_success(): # URL shortening functionality
def test_redirect_success():   # URL redirection
def test_get_stats_success():  # Statistics retrieval
def test_redis_connection_error(): # Error handling
```

**Why Testing Matters:**
- **Prevents regressions** when code changes
- **Documents expected behavior** for other developers
- **Enables confident deployments** in CI/CD pipelines
- **Catches issues early** in development cycle

---

## ⚡ Step 4: Building Your First Docker Image

**File Location:** `/Learn_Docker_kubernetes/shortly/backend/Dockerfile`

### **Understanding Multi-Stage Builds**

Our Dockerfile uses a **multi-stage build** pattern:

```dockerfile
# Stage 1: Build stage
FROM python:3.11-slim as builder
# Install dependencies and build requirements

# Stage 2: Production stage  
FROM python:3.11-slim as production
# Copy only what's needed for runtime
```

**Why Multi-Stage Builds?**
- **Smaller final images** (no build tools in production)
- **Better security** (fewer attack surfaces)
- **Faster deployments** (smaller images transfer faster)
- **Layer caching** (build dependencies cached separately)

### **Security Best Practices in Our Dockerfile**

**1. Non-Root User:**
```dockerfile
RUN groupadd -r appuser && useradd -r -g appuser appuser
USER appuser
```

**2. Minimal Base Image:**
```dockerfile
FROM python:3.11-slim  # Instead of full python image
```

**3. Health Checks:**
```dockerfile
HEALTHCHECK --interval=30s --timeout=10s --start-period=5s --retries=3 \
    CMD curl -f http://localhost:8000/health || exit 1
```

**4. Proper File Permissions:**
```dockerfile
COPY --chown=appuser:appuser app/ ./app/
```

### **Build the Docker Image**

**Command:**
```bash
# Navigate to backend directory
cd /Learn_Docker_kubernetes/shortly/backend

# Build the image
docker build -t shortly-backend:latest .
```

**Expected Output:**
```
[+] Building 45.2s (15/15) FINISHED
 => [internal] load build definition from Dockerfile
 => [internal] load .dockerignore
 => [internal] load metadata for docker.io/library/python:3.11-slim
 => [builder 1/6] FROM docker.io/library/python:3.11-slim
 => [internal] load build context
 => [builder 2/6] RUN apt-get update && apt-get install -y gcc
 => [builder 3/6] WORKDIR /app
 => [builder 4/6] COPY requirements.txt .
 => [builder 5/6] RUN pip install --no-cache-dir -r requirements.txt
 => [production 1/7] FROM docker.io/library/python:3.11-slim
 => [production 2/7] RUN groupadd -r appuser && useradd -r -g appuser appuser
 => [production 3/7] RUN apt-get update && apt-get install -y curl
 => [production 4/7] WORKDIR /app
 => [production 5/7] COPY --from=builder /usr/local/lib/python3.11/site-packages
 => [production 6/7] COPY --chown=appuser:appuser app/ ./app/
 => [production 7/7] USER appuser
 => exporting to image
 => => naming to docker.io/library/shortly-backend:latest
```

### **Verify the Image**

```bash
# List Docker images
docker images | grep shortly-backend

# Inspect the image
docker inspect shortly-backend:latest
```

---

## ⚡ Step 5: Running the Container

### **Start Redis Container**

First, we need Redis for our application:
```bash
# Run Redis in a container
docker run -d \
  --name redis \
  --network bridge \
  -p 6379:6379 \
  redis:7-alpine
```

### **Run the FastAPI Container**

```bash
# Run our FastAPI application
docker run -d \
  --name shortly-backend \
  --network bridge \
  -p 8000:8000 \
  -e REDIS_HOST=redis \
  --link redis:redis \
  shortly-backend:latest
```

**Command Breakdown:**
- `-d` - Run in detached mode (background)
- `--name` - Assign a name to the container
- `--network bridge` - Use Docker's default bridge network
- `-p 8000:8000` - Map host port 8000 to container port 8000
- `-e REDIS_HOST=redis` - Set environment variable
- `--link redis:redis` - Link to Redis container

### **Verify the Application**

**Check container status:**
```bash
docker ps
```

**Test the health endpoint:**
```bash
curl http://localhost:8000/health
```

**Expected Response:**
```json
{
  "status": "healthy",
  "redis": "healthy", 
  "version": "1.0.0",
  "redis_ping": "ok"
}
```

**Test URL shortening:**
```bash
# Create a short URL
curl -X POST "http://localhost:8000/shorten" \
  -H "Content-Type: application/json" \
  -d '{"url": "https://example.com/very/long/path"}'
```

**Expected Response:**
```json
{
  "short_url": "http://localhost:8000/abc123",
  "original_url": "https://example.com/very/long/path", 
  "short_code": "abc123"
}
```

---

## ✅ Verification Checklist

Before proceeding to the next step, verify:

- [ ] Docker image builds successfully
- [ ] Container starts without errors
- [ ] Health check endpoint returns 200
- [ ] URL shortening works correctly
- [ ] Redis connection is established
- [ ] Application logs show no errors

**Check logs if issues occur:**
```bash
# View application logs
docker logs shortly-backend

# View Redis logs  
docker logs redis
```

---

## 🐛 Common Issues & Troubleshooting

### **Issue: "Port already in use"**
**Symptoms:** `bind: address already in use`
**Solution:**
```bash
# Find process using port 8000
lsof -i :8000  # macOS/Linux
netstat -ano | findstr :8000  # Windows

# Kill the process or use different port
docker run -p 8001:8000 shortly-backend:latest
```

### **Issue: "Redis connection failed"**
**Symptoms:** `Redis connection not available`
**Solution:**
```bash
# Check if Redis is running
docker ps | grep redis

# Check Redis logs
docker logs redis

# Restart Redis if needed
docker restart redis
```

### **Issue: "Module not found"**
**Symptoms:** `ModuleNotFoundError: No module named 'app'`
**Solution:**
```bash
# Verify file structure in container
docker exec -it shortly-backend ls -la /app

# Check if app directory exists
docker exec -it shortly-backend ls -la /app/app
```

---

## 🏢 Enterprise Context

### **Why This Matters in Production**

**1. Consistency Across Environments:**
- Development, staging, and production use identical containers
- Eliminates "works on my machine" problems
- Predictable behavior across different infrastructure

**2. Scalability:**
- Containers can be horizontally scaled
- Load balancers can distribute traffic across multiple instances
- Auto-scaling based on metrics

**3. Security:**
- Isolated application environments
- Non-root user execution
- Minimal attack surface with slim images

**4. Operational Excellence:**
- Health checks enable automated monitoring
- Structured logging for observability
- Graceful shutdown handling

---

---

## 🚀 Project 2: Building the React Frontend

### **What We're Building**

A modern React-based frontend for the Shortly URL shortener:
- **Modern UI** with glassmorphism design
- **Form validation** and error handling
- **API integration** with FastAPI backend
- **Copy-to-clipboard** functionality
- **Production-ready** Nginx configuration

### **Frontend Architecture**
```
┌─────────────────┐    HTTP     ┌─────────────────┐    Proxy    ┌─────────────────┐
│   User Browser  │ ──────────► │  Nginx (Port 80)│ ──────────► │ FastAPI Backend │
│                 │             │  React App      │             │  (Port 8000)    │
└─────────────────┘             └─────────────────┘             └─────────────────┘
```

### **Key Frontend Components**

**File Structure:**
```
/Learn_Docker_kubernetes/shortly/frontend/
├── public/
│   └── index.html              # HTML template
├── src/
│   ├── components/
│   │   ├── UrlShortener.js     # Main component
│   │   ├── UrlShortener.css    # Component styling
│   │   └── UrlShortener.test.js # Component tests
│   ├── App.js                  # Root component
│   ├── App.css                 # App styling
│   └── index.js                # React entry point
├── Dockerfile                  # Multi-stage build
├── nginx.conf                  # Production web server config
└── package.json               # Dependencies and scripts
```

### **Multi-Stage Dockerfile for React + Nginx**

```dockerfile
# Stage 1: Build React application
FROM node:18-alpine AS builder
WORKDIR /app
COPY package.json package-lock.json* ./
RUN npm ci --only=production && npm cache clean --force
COPY public/ ./public/
COPY src/ ./src/
RUN npm run build

# Stage 2: Serve with Nginx
FROM nginx:alpine AS production
RUN apk add --no-cache curl
RUN rm -rf /usr/share/nginx/html/*
COPY --from=builder /app/build /usr/share/nginx/html
COPY nginx.conf /etc/nginx/conf.d/default.conf

# Handle permissions for non-root nginx
RUN chown -R nginx:nginx /usr/share/nginx/html && \
    chown -R nginx:nginx /var/cache/nginx && \
    chown -R nginx:nginx /var/log/nginx && \
    chown -R nginx:nginx /etc/nginx/conf.d && \
    mkdir -p /run && \
    chown -R nginx:nginx /run

USER nginx
EXPOSE 80
HEALTHCHECK --interval=30s --timeout=3s --start-period=5s --retries=3 \
    CMD curl -f http://localhost/health || exit 1
CMD ["nginx", "-g", "daemon off;"]
```

---

## 🚀 Project 3: Docker Compose Orchestration

### **What We're Building**

A complete multi-service application using Docker Compose:
- **Service Discovery** - Containers communicate by service name
- **Dependency Management** - Services start in correct order
- **Environment Configuration** - Centralized configuration
- **Data Persistence** - Redis data survives container restarts

### **Docker Compose Architecture**
```
Docker Compose Network (shortly_default)
┌─────────────────────────────────────────────────────────────┐
│                                                             │
│  ┌─────────────┐    ┌─────────────┐    ┌─────────────┐     │
│  │   Redis     │    │   Backend   │    │  Frontend   │     │
│  │ Port: 6379  │◄───│ Port: 8000  │◄───│ Port: 3000  │     │
│  │             │    │             │    │ (Nginx:80)  │     │
│  └─────────────┘    └─────────────┘    └─────────────┘     │
│                                                             │
└─────────────────────────────────────────────────────────────┘
         ▲                    ▲                    ▲
    localhost:6379    localhost:8000        localhost:3000
```

### **Complete Docker Compose Configuration**

**File Location:** `/Learn_Docker_kubernetes/shortly/docker-compose.yml`

```yaml
version: '3.8'

services:
  redis:
    image: redis:7-alpine
    container_name: shortly-redis
    ports:
      - "6379:6379"
    volumes:
      - redis_data:/data
    command: redis-server --appendonly yes

  backend:
    build:
      context: ./backend
      dockerfile: Dockerfile
    container_name: shortly-backend
    ports:
      - "8000:8000"
    environment:
      - REDIS_HOST=redis
      - REDIS_PORT=6379
      - REDIS_DB=0
    depends_on:
      - redis
    volumes:
      - ./backend:/app
    command: uvicorn app.main:app --host 0.0.0.0 --port 8000 --reload

  frontend:
    build:
      context: ./frontend
      dockerfile: Dockerfile
    container_name: shortly-frontend
    ports:
      - "3000:80"
    environment:
      - REACT_APP_API_URL=http://localhost:8000
    depends_on:
      - backend

volumes:
  redis_data:
```

### **Key Docker Compose Concepts**

**1. Service Discovery:**
```yaml
# Backend connects to Redis using service name
environment:
  - REDIS_HOST=redis  # Not localhost!
```

**2. Dependency Management:**
```yaml
# Ensures Redis starts before backend
depends_on:
  - redis
```

**3. Volume Persistence:**
```yaml
# Data survives container restarts
volumes:
  - redis_data:/data
```

**4. Network Isolation:**
```yaml
# All services on same network by default
# Can communicate using service names
```

### **Common Docker Compose Commands**

```bash
# Build and start all services
docker-compose up --build

# Start in background
docker-compose up -d

# View logs
docker-compose logs -f

# Stop all services
docker-compose down

# Stop and remove volumes
docker-compose down --volumes

# Rebuild specific service
docker-compose up frontend --build
```

---

## 🐛 Real-World Troubleshooting: Lessons Learned

### **Issue 1: Nginx Permission Errors**

**Problem:**
```
nginx: [emerg] open() "/run/nginx.pid" failed (13: Permission denied)
```

**Root Cause:** Running nginx as non-root user without proper directory permissions.

**Solution:**
```dockerfile
# Create and set permissions for both PID locations
RUN mkdir -p /var/run/nginx && \
    chown -R nginx:nginx /var/run/nginx && \
    mkdir -p /run && \
    chown -R nginx:nginx /run
```

**Learning:** Container security (non-root users) requires careful permission management.

### **Issue 2: Docker Build Cache Corruption**

**Problem:**
```
failed to prepare extraction snapshot: parent snapshot does not exist
```

**Root Cause:** Docker layer cache corruption during builds.

**Solution:**
```bash
# Clear Docker cache completely
docker-compose down --volumes --remove-orphans
docker system prune -f
docker builder prune -f
docker-compose up --build --force-recreate
```

**Learning:** Cache issues are common in CI/CD - always have cache clearing strategies.

### **Issue 3: Complex Nginx Regex Failures**

**Problem:**
```
nginx: [emerg] pcre2_compile() failed: missing closing parenthesis
```

**Root Cause:** Complex regex patterns in nginx location blocks.

**Solution:** Simplify configuration using explicit location blocks:
```nginx
# Instead of complex regex
location ~ ^/[a-zA-Z0-9]{3,}$ { ... }

# Use simple patterns
location /shorten { ... }
location /api/ { ... }
location / { ... }
```

**Learning:** KISS principle - Keep It Simple, Stupid. Simple configs are more reliable.

### **Issue 4: Service Communication Problems**

**Problem:** Backend couldn't connect to Redis.

**Root Cause:** Wrong environment variable format.

**Solution:**
```yaml
# Wrong: Using connection string format
environment:
  - REDIS_URL=redis://redis:6379

# Right: Using individual variables as expected by app
environment:
  - REDIS_HOST=redis
  - REDIS_PORT=6379
  - REDIS_DB=0
```

**Learning:** Always check how your application expects configuration.

---

## ✅ Complete Verification Checklist

### **End-to-End Testing**

Before proceeding to AWS deployment, verify:

**1. All Services Running:**
```bash
docker-compose ps
# Should show all services as "Up"
```

**2. Frontend Accessible:**
- [ ] Visit `http://localhost:3000`
- [ ] React app loads without errors
- [ ] Form is visible and functional

**3. Backend API Working:**
```bash
# Health check
curl http://localhost:8000/health

# Create short URL
curl -X POST "http://localhost:8000/shorten" \
  -H "Content-Type: application/json" \
  -d '{"url": "https://github.com/your-username/Learn_Docker_kubernetes"}'
```

**4. End-to-End Flow:**
- [ ] Enter URL in frontend form
- [ ] Short URL is generated and displayed
- [ ] Copy-to-clipboard works
- [ ] Short URL redirects correctly
- [ ] Statistics are tracked

**5. Data Persistence:**
```bash
# Stop and restart services
docker-compose down
docker-compose up -d

# Verify data persists
curl http://localhost:8000/stats/{short_code}
```

---

## 🏢 Enterprise Insights

### **Production Considerations**

**1. Security Best Practices Applied:**
- Non-root users in all containers
- Minimal base images (Alpine Linux)
- Health checks for monitoring
- Proper file permissions

**2. Scalability Patterns:**
- Stateless application design
- External data storage (Redis)
- Load balancer ready (Nginx)
- Environment-based configuration

**3. Operational Excellence:**
- Structured logging to stdout/stderr
- Health check endpoints
- Graceful shutdown handling
- Resource constraint awareness

### **DevOps Skills Demonstrated**

**1. Container Debugging:**
- Log analysis and interpretation
- Permission troubleshooting
- Network connectivity testing
- Cache management

**2. Configuration Management:**
- Environment variable strategies
- Service discovery patterns
- Dependency management
- Volume persistence

**3. Progressive Problem Solving:**
- Start complex, simplify when needed
- Isolate issues systematically
- Document solutions for team knowledge
- Test fixes incrementally

---

## 🎯 Next Steps

**✅ Phase 1 Complete: Full-Stack Containerization**

You've successfully built a production-ready containerized application! 

**Next: Phase 2 - Cloud Deployment**

1. **Project 4: AWS EC2 "Lift and Shift"** - Deploy to public cloud
2. **Project 5: Infrastructure as Code** - Terraform automation
3. **Project 6: Kubernetes on EKS** - Container orchestration at scale

**Continue to:** [03-aws-infrastructure.md](./03-aws-infrastructure.md)

---

## 📚 Additional Resources

- [Docker Best Practices](https://docs.docker.com/develop/dev-best-practices/)
- [FastAPI Documentation](https://fastapi.tiangolo.com/)
- [Multi-stage Builds](https://docs.docker.com/develop/multistage-build/)
- [Container Security](https://docs.docker.com/engine/security/)

---

**🎉 Congratulations!** You've built your first production-ready containerized application! 