# DevOps Engineer Interview Preparation

**Target Role:** TCS Kubernetes/DevOps Engineer  
**Learning Journey:** Docker Containerization → AWS Cloud Deployment → Kubernetes (Planned)  
**Application:** Shortly URL Shortener (Production Deployed)

---

## Table of Contents

1. [Container Fundamentals](#container-fundamentals)
2. [Cloud Infrastructure](#cloud-infrastructure)
3. [Production Operations](#production-operations)
4. [Troubleshooting & Monitoring](#troubleshooting--monitoring)
5. [Automation & CI/CD](#automation--cicd)
6. [Kubernetes Bridge Concepts](#kubernetes-bridge-concepts)
7. [Behavioral Questions](#behavioral-questions)

---

## Container Fundamentals

### Q1: How do containers communicate in Docker Compose?

**Your Experience:** "In my Shortly URL shortener application..."

**Technical Answer:**
In Docker Compose, containers communicate through a **default bridge network** with automatic service discovery:

- **Service Names as Hostnames:** Frontend connects to backend via `http://backend:8000`, backend connects to Redis via `redis:6379`
- **Internal DNS Resolution:** Docker Compose creates internal DNS that resolves service names to container IPs
- **Network Isolation:** All services run on the same Docker network, isolated from host network
- **Port Mapping vs Internal Communication:** 
  - External access: `localhost:3000` → Frontend container
  - Internal communication: `backend:8000` (no port mapping needed)

**Bridge to Kubernetes:** "This translates directly to Kubernetes Services and pod networking, where service discovery works similarly but at enterprise scale."

---

### Q2: What networking challenges arise when scaling to multiple backend instances?

**Your Experience:** "When I think about scaling my FastAPI backend..."

**Technical Answer:**
Multiple backend instances create several challenges:

1. **Port Conflicts:** Can't bind multiple containers to the same host port (8000)
2. **Load Balancing:** Need to distribute incoming requests across all instances
3. **Service Discovery:** Frontend needs to know about all backend instances dynamically
4. **Session State:** If backend stores user sessions, they're not shared between instances
5. **Database Connection Pooling:** Redis might get overwhelmed with connections from multiple backends
6. **Health Monitoring:** Need to track health of each instance individually

**Solutions:**
- **Docker Compose scaling:** `docker-compose up --scale backend=3`
- **Load balancer:** Nginx upstream configuration
- **Shared state:** Use Redis for session storage
- **Connection pooling:** Limit database connections per instance

**Bridge to Kubernetes:** "Kubernetes solves this with Services, ReplicaSets, and built-in load balancing."

---

### Q3: Why is container isolation important?

**Your Experience:** "In my production deployment..."

**Technical Answer:**
Container isolation uses **Linux namespaces** and **cgroups** to provide:

1. **Process Isolation:** Each container has its own process tree (PID namespace)
2. **Network Isolation:** Separate network stack per container (network namespace)
3. **Filesystem Isolation:** Each container has its own filesystem view (mount namespace)
4. **Resource Isolation:** CPU/memory limits prevent resource conflicts (cgroups)
5. **Security Isolation:** Prevents containers from accessing each other's data

**Benefits:**
- **Fault Tolerance:** One container crash doesn't affect others
- **Security Boundaries:** Compromised container can't access others
- **Resource Predictability:** Guaranteed resources per container
- **Development Consistency:** Same environment across dev/staging/prod

**Real Example:** "In my Shortly app, if the Redis container crashes, my FastAPI and React containers continue running, and Docker Compose automatically restarts Redis."

---

## Cloud Infrastructure

### Q4: What bottlenecks would occur with 1000 concurrent users?

**Your Experience:** "My current single EC2 instance setup would face..."

**Technical Answer:**
Current bottlenecks with high traffic:

1. **Compute Resources:**
   - Single backend instance CPU/memory limits
   - Nginx SSL termination overhead
   - Container resource contention

2. **Network Limitations:**
   - EC2 instance bandwidth limits
   - Single point of network failure
   - Geographic latency for global users

3. **Database Performance:**
   - Redis memory constraints
   - Limited concurrent connections
   - Single Redis instance bottleneck

4. **Storage I/O:**
   - Docker log volume
   - Redis persistence overhead
   - EBS IOPS limitations

**Scaling Solutions:**
- **Horizontal scaling:** Multiple EC2 instances with load balancer
- **Database scaling:** Redis clustering or managed ElastiCache
- **CDN:** CloudFront for static assets
- **Auto Scaling Groups:** Dynamic instance scaling

**Bridge to Kubernetes:** "Kubernetes addresses this with horizontal pod autoscaling, resource quotas, and built-in load balancing."

---

### Q5: How would you ensure high availability?

**Your Experience:** "Moving from my single EC2 setup to high availability..."

**Technical Answer:**
High availability strategy:

1. **Infrastructure Level:**
   - **Multi-AZ deployment:** Spread across availability zones
   - **Auto Scaling Groups:** Replace failed instances automatically
   - **Elastic Load Balancer:** Health checks and traffic routing
   - **Infrastructure as Code:** Quick recreation with Terraform

2. **Application Level:**
   - **Stateless design:** No local state in application containers
   - **Health checks:** Liveness and readiness probes
   - **Graceful shutdown:** Handle SIGTERM signals properly
   - **Circuit breakers:** Fail fast when dependencies are down

3. **Data Level:**
   - **Redis clustering:** Master-slave replication
   - **Automated backups:** Regular snapshots to S3
   - **Point-in-time recovery:** Multiple backup retention periods
   - **Cross-region replication:** Disaster recovery

**Current Implementation:** "I have basic backup automation and health checks, but need to implement multi-AZ and auto-scaling for true HA."

---

## Production Operations

### Q6: How do you manage configuration across environments?

**Your Experience:** "In my Shortly app deployment..."

**Technical Answer:**
Configuration management strategy:

1. **Environment Variables:**
   ```bash
   # Development
   REDIS_HOST=localhost
   BASE_URL=http://localhost:8000
   
   # Production  
   REDIS_HOST=redis
   BASE_URL=https://shortly-somesh.duckdns.org
   ```

2. **Docker Compose Environment Files:**
   ```yaml
   # docker-compose.yml
   environment:
     - REDIS_HOST=${REDIS_HOST}
     - BASE_URL=${BASE_URL}
   
   # .env.development
   REDIS_HOST=localhost
   
   # .env.production
   REDIS_HOST=redis
   ```

3. **Build vs Runtime Configuration:**
   - **Build-time (ARG):** Base images, package versions
   - **Runtime (ENV):** Database connections, API endpoints

4. **Secret Management:**
   - **Environment variables:** Non-sensitive config
   - **Docker secrets:** Passwords, API keys
   - **External stores:** AWS Secrets Manager for production

**Bridge to Kubernetes:** "Kubernetes uses ConfigMaps for configuration and Secrets for sensitive data, with similar patterns but better secret management."

---

### Q7: How do you handle service discovery?

**Your Experience:** "In my Docker Compose setup..."

**Technical Answer:**
Service discovery implementation:

1. **Current Docker Compose Approach:**
   ```yaml
   # Frontend connects to backend
   REACT_APP_API_URL=http://backend:8000
   
   # Backend connects to Redis
   REDIS_HOST=redis
   REDIS_PORT=6379
   ```

2. **DNS-Based Discovery:**
   - Docker Compose creates internal DNS
   - Service names resolve to container IPs
   - Automatic updates when containers restart

3. **Challenges with Scaling:**
   - Static configuration doesn't handle multiple instances
   - Need load balancing across service instances
   - Health checking for service availability

4. **Enterprise Solutions:**
   - **Service mesh:** Istio, Linkerd for microservices
   - **API Gateway:** Single entry point with routing
   - **Service registry:** Consul, etcd for dynamic discovery

**Real Example:** "My frontend knows to call `/api` endpoints, and Nginx routes these to the backend container automatically."

---

## Troubleshooting & Monitoring

### Q8: How do you troubleshoot container issues?

**Your Experience:** "When I had the health check issue..."

**Technical Answer:**
Systematic troubleshooting approach:

1. **Container Status Check:**
   ```bash
   docker-compose ps                    # Container states
   docker-compose logs backend          # Application logs
   docker stats                         # Resource usage
   docker inspect shortly-backend       # Container details
   ```

2. **Application Level:**
   ```bash
   curl http://localhost:8000/health    # Health endpoint
   docker exec -it shortly-backend bash # Interactive debugging
   cat /var/log/nginx/error.log         # Web server logs
   ```

3. **Network Debugging:**
   ```bash
   docker network ls                    # Available networks
   docker network inspect shortly_default # Network details
   nslookup backend                     # DNS resolution
   ```

4. **Real Issue Example:**
   - **Problem:** Backend showing "unhealthy" status
   - **Investigation:** Health endpoint returning 500 errors
   - **Root Cause:** FastAPI route ordering conflict (`/health` vs `/{short_code}`)
   - **Solution:** Moved specific routes before generic catch-all routes

**Troubleshooting Mindset:** "Start with symptoms, gather data, form hypothesis, test systematically."

---

### Q9: What monitoring do you implement?

**Your Experience:** "In my production deployment..."

**Technical Answer:**
Comprehensive monitoring strategy:

1. **Application Monitoring:**
   ```bash
   # Health checks
   curl https://shortly-somesh.duckdns.org/health
   
   # Performance metrics
   curl -w "Time: %{time_total}s\n" -o /dev/null -s https://shortly-somesh.duckdns.org
   ```

2. **Infrastructure Monitoring:**
   ```bash
   # System resources
   htop                    # CPU, memory usage
   df -h                   # Disk space
   docker stats --no-stream # Container resources
   ```

3. **Log Management:**
   ```bash
   # Centralized logging
   docker-compose logs -f
   
   # Log rotation (automated)
   /etc/logrotate.d/docker
   ```

4. **Automated Health Checks:**
   ```bash
   # Custom health check script
   /usr/local/bin/health-check.sh
   
   # Cron-based monitoring
   0 */6 * * * /usr/local/bin/health-check.sh
   ```

5. **Alerting Strategy:**
   - **SSL certificate expiration** (Let's Encrypt auto-renewal)
   - **Disk space warnings** (>85% usage)
   - **Container restart alerts** (Docker health checks)
   - **Response time degradation** (>2 second response times)

**Bridge to Kubernetes:** "Kubernetes provides built-in monitoring with Prometheus, Grafana, and advanced observability tools."

---

## Automation & CI/CD

### Q10: Describe your deployment process

**Your Experience:** "My current Git-to-production workflow..."

**Technical Answer:**
Current deployment pipeline:

1. **Development Workflow:**
   ```bash
   # Local development
   git checkout -b feature/new-endpoint
   # Make changes, test locally
   docker-compose up -d
   
   # Commit and push
   git add .
   git commit -m "Add new API endpoint"
   git push origin feature/new-endpoint
   ```

2. **Production Deployment:**
   ```bash
   # On production server
   git pull origin main
   docker-compose down
   docker-compose up -d --build
   
   # Verify deployment
   curl https://shortly-somesh.duckdns.org/health
   ```

3. **Manual Steps to Automate:**
   - **Testing:** Automated test execution
   - **Building:** Automated image builds
   - **Deployment:** Zero-downtime deployments
   - **Verification:** Automated smoke tests
   - **Rollback:** Automated rollback on failure

4. **Ideal CI/CD Pipeline:**
   ```yaml
   # Jenkinsfile (planned)
   pipeline {
     stages {
       stage('Test') { /* Run pytest, npm test */ }
       stage('Build') { /* Build Docker images */ }
       stage('Deploy') { /* Update production */ }
       stage('Verify') { /* Health checks */ }
     }
   }
   ```

**Current Limitations:** "Manual deployment process, no automated testing, potential downtime during updates."

**Bridge to Kubernetes:** "Kubernetes enables GitOps workflows with automated deployments, rolling updates, and built-in rollback capabilities."

---

### Q11: How would you implement Infrastructure as Code?

**Your Experience:** "Currently, I manually created my AWS infrastructure..."

**Technical Answer:**
Infrastructure as Code implementation:

1. **Current Manual Process:**
   - AWS CLI commands for security groups
   - Manual EC2 instance creation
   - Manual domain configuration
   - Manual SSL certificate setup

2. **Terraform Implementation (Planned):**
   ```hcl
   # main.tf
   resource "aws_instance" "shortly_server" {
     ami           = "ami-0fa9de2bba4d18c53"
     instance_type = "t3.micro"
     key_name      = aws_key_pair.shortly_key.key_name
     
     vpc_security_group_ids = [aws_security_group.shortly_sg.id]
     
     tags = {
       Name = "shortly-server"
       Project = "DevOps-Learning"
     }
   }
   ```

3. **Benefits of IaC:**
   - **Version Control:** Infrastructure changes tracked in Git
   - **Reproducibility:** Identical environments every time
   - **Collaboration:** Team can review infrastructure changes
   - **Automation:** Integrate with CI/CD pipelines
   - **Documentation:** Code serves as documentation

4. **Planned Implementation:**
   - **Terraform modules:** Reusable infrastructure components
   - **State management:** Remote state in S3
   - **Environment separation:** Dev/staging/prod configurations
   - **Automated testing:** Terraform plan validation

**Current Gap:** "I understand the infrastructure requirements but need to codify them for repeatability and automation."

---

## Kubernetes Bridge Concepts

### Q12: How does your Docker Compose experience relate to Kubernetes?

**Your Experience:** "My Docker Compose setup translates to Kubernetes..."

**Technical Answer:**
Docker Compose to Kubernetes mapping:

1. **Service Definition:**
   ```yaml
   # Docker Compose
   services:
     backend:
       build: ./backend
       ports:
         - "8000:8000"
       environment:
         - REDIS_HOST=redis
   
   # Kubernetes Equivalent
   apiVersion: apps/v1
   kind: Deployment
   metadata:
     name: backend
   spec:
     replicas: 3
     selector:
       matchLabels:
         app: backend
     template:
       spec:
         containers:
         - name: backend
           image: shortly-backend:latest
           ports:
           - containerPort: 8000
           env:
           - name: REDIS_HOST
             value: "redis"
   ```

2. **Networking:**
   - **Docker Compose:** Service names for DNS resolution
   - **Kubernetes:** Services provide stable endpoints for pods

3. **Scaling:**
   - **Docker Compose:** `docker-compose up --scale backend=3`
   - **Kubernetes:** `kubectl scale deployment backend --replicas=3`

4. **Health Checks:**
   - **Docker Compose:** Basic health check commands
   - **Kubernetes:** Liveness, readiness, and startup probes

**Key Advantages of Kubernetes:**
- **Automatic scaling:** Based on CPU/memory usage
- **Self-healing:** Automatic pod replacement
- **Rolling updates:** Zero-downtime deployments
- **Resource management:** Better resource allocation
- **Enterprise features:** RBAC, network policies, secrets management

---

### Q13: What Kubernetes concepts would you need to learn?

**Your Experience:** "Based on my containerization experience..."

**Technical Answer:**
Learning path from Docker Compose to Kubernetes:

1. **Core Concepts (Building on Docker knowledge):**
   - **Pods:** Groups of containers (like Docker Compose services)
   - **Deployments:** Manage pod replicas (like scaling in Compose)
   - **Services:** Network endpoints (like service names in Compose)
   - **ConfigMaps/Secrets:** Configuration management (like environment variables)

2. **Kubernetes-Specific Concepts:**
   - **Namespaces:** Environment isolation
   - **Ingress:** External access (like Nginx reverse proxy)
   - **Persistent Volumes:** Data persistence (like Docker volumes)
   - **Resource Quotas:** Resource limits and requests

3. **Operational Concepts:**
   - **kubectl:** Command-line tool (like docker-compose CLI)
   - **YAML manifests:** Declarative configuration (like docker-compose.yml)
   - **Helm:** Package manager (like Docker Compose for complex apps)

4. **Advanced Features:**
   - **Horizontal Pod Autoscaler:** Automatic scaling
   - **Network Policies:** Security between pods
   - **Service Mesh:** Advanced networking (Istio)
   - **Operators:** Custom resource management

**Learning Strategy:** "Start with basic pod/service concepts, then gradually add complexity like scaling, persistence, and security."

---

## Behavioral Questions

### Q14: Describe a challenging technical problem you solved

**Your Experience:** "During my Shortly app deployment..."

**STAR Method Answer:**

**Situation:** "While deploying my URL shortener to AWS, I encountered a critical issue where the application was accessible but the health checks were failing, causing the containers to be marked as unhealthy."

**Task:** "I needed to diagnose why the health endpoint was returning 500 errors and fix it to ensure proper monitoring and container orchestration."

**Action:** 
1. "I systematically investigated by checking container logs with `docker-compose logs backend`"
2. "I tested the health endpoint directly with `curl` and found it was returning 500 errors"
3. "I analyzed the FastAPI route definitions and discovered a route ordering conflict"
4. "The generic `/{short_code}` route was catching `/health` requests before the specific health route"
5. "I restructured the routes, placing specific routes before generic catch-all routes"
6. "I tested the fix locally first, then deployed to production"

**Result:** "The health checks started passing, containers were marked as healthy, and I gained valuable experience in production debugging. This also taught me the importance of route ordering in web frameworks and systematic troubleshooting approaches."

**Learning:** "This experience reinforced the importance of testing all endpoints thoroughly and understanding how routing precedence works in web frameworks."

---

### Q15: How do you stay updated with DevOps technologies?

**Your Experience:** "My continuous learning approach..."

**Technical Answer:**

1. **Hands-on Learning:**
   - "I build real projects like my Shortly URL shortener to understand concepts practically"
   - "I deploy to actual cloud infrastructure rather than just local development"
   - "I document my learning journey and create comprehensive guides"

2. **Structured Learning:**
   - "I follow a progressive learning path: Docker → AWS → Kubernetes → CI/CD"
   - "I focus on understanding fundamentals before moving to advanced topics"
   - "I align my learning with industry job requirements like this TCS role"

3. **Community Engagement:**
   - "I study real-world job descriptions to understand market demands"
   - "I analyze enterprise architecture patterns and best practices"
   - "I practice explaining concepts to reinforce my understanding"

4. **Practical Application:**
   - "I implement production-ready features like HTTPS, monitoring, and backups"
   - "I solve real problems like scaling challenges and security requirements"
   - "I maintain and operate my deployments to understand operational challenges"

**Future Learning:** "I'm planning to learn Kubernetes next, followed by CI/CD pipelines with Jenkins, to build a complete DevOps skill set aligned with enterprise requirements."

---

## Interview Tips

### Technical Discussion Strategy

1. **Start with Your Experience:** Always begin with "In my Shortly application..." or "When I deployed to AWS..."

2. **Show Problem-Solving:** Explain your thought process, not just the solution

3. **Connect to Enterprise Scale:** Bridge your learning to production requirements

4. **Demonstrate Growth Mindset:** Show eagerness to learn Kubernetes and advanced concepts

5. **Use Specific Examples:** Reference actual commands, configurations, and outcomes

### Key Phrases to Use

- "In my production deployment experience..."
- "When I encountered this issue, I systematically..."
- "This translates to Kubernetes as..."
- "I'm excited to learn how Kubernetes solves this at enterprise scale..."
- "My containerization foundation prepares me for..."

### Questions to Ask Interviewer

1. "What Kubernetes distributions does TCS use in production?"
2. "How does the team handle multi-environment deployments?"
3. "What monitoring and observability tools are standard?"
4. "What's the typical learning curve for new team members?"
5. "How does the team stay updated with Kubernetes ecosystem changes?"

---

## Assessment Questions from Learning Session

### Q16: What's the difference between a Docker image and a Docker container?

**Your Experience:** "In my Shortly application development..."

**Technical Answer:**
The relationship between Docker images and containers is fundamental to containerization:

**Docker Image:**
- **Static blueprint:** Read-only template containing application code, dependencies, and runtime
- **Layered filesystem:** Built using Dockerfile instructions, each creating a new layer
- **Immutable:** Once built, cannot be changed (must rebuild for modifications)
- **Shareable:** Can be stored in registries and distributed across environments
- **Example:** `shortly-backend:latest` image contains FastAPI code, Python runtime, and dependencies

**Docker Container:**
- **Running instance:** Live execution of a Docker image with writable layer on top
- **Process isolation:** Has its own filesystem, network, and process space
- **Stateful:** Can write data, modify files (in writable layer)
- **Ephemeral:** Can be stopped, started, deleted without affecting the image
- **Example:** `shortly-backend` container running from the image, handling HTTP requests

**Real-world Analogy:**
- **Image = Class:** Blueprint defining structure and behavior
- **Container = Object:** Instance of the class with actual state and execution

**In My Project:**
```bash
# Image (blueprint)
docker build -t shortly-backend ./backend

# Container (running instance)
docker run -d --name backend-instance shortly-backend
```

---

### Q17: How do you ensure your containers are production-ready?

**Your Experience:** "When I deployed Shortly to AWS production..."

**Technical Answer:**
Production readiness involves multiple layers of preparation:

**1. Health Checks and Monitoring:**
```dockerfile
# Dockerfile health check
HEALTHCHECK --interval=30s --timeout=3s --start-period=5s --retries=3 \
  CMD curl -f http://localhost:8000/health || exit 1
```

**2. Resource Management:**
```yaml
# docker-compose.yml
services:
  backend:
    deploy:
      resources:
        limits:
          memory: 512M
          cpus: '0.5'
        reservations:
          memory: 256M
          cpus: '0.25'
```

**3. Security Hardening:**
- **Non-root user:** Run containers with limited privileges
- **Minimal base images:** Use Alpine or distroless images
- **Secret management:** Environment variables for sensitive data
- **Network isolation:** Proper firewall and security group configuration

**4. Logging and Observability:**
```bash
# Structured logging
docker-compose logs --tail=100 backend

# Log rotation to prevent disk issues
/etc/logrotate.d/docker
```

**5. Backup and Recovery:**
- **Data persistence:** Redis backup automation with cron jobs
- **Configuration backup:** Version-controlled docker-compose files
- **Disaster recovery:** Documented restoration procedures

**Real Implementation in My Project:**
- SSL certificates with auto-renewal
- UFW firewall with minimal port access
- Automated health monitoring scripts
- 7-day backup retention policy
- Resource monitoring with htop and docker stats

---

### Q18: What happens when you run `docker-compose up`?

**Your Experience:** "When I deploy my Shortly application..."

**Technical Answer:**
`docker-compose up` executes a complex orchestration sequence:

**1. Configuration Parsing:**
- Reads `docker-compose.yml` and any override files
- Validates service definitions and dependencies
- Resolves environment variables from `.env` files

**2. Network Creation:**
```bash
# Creates default network
docker network create shortly_default
```

**3. Volume Creation:**
```bash
# Creates named volumes if defined
docker volume create shortly_redis_data
```

**4. Image Building/Pulling:**
```bash
# For services with 'build' directive
docker build -t shortly-backend ./backend

# For services with 'image' directive  
docker pull redis:7-alpine
```

**5. Container Creation and Startup:**
```bash
# Creates containers in dependency order
docker create --name shortly-redis redis:7-alpine
docker create --name shortly-backend shortly-backend
docker create --name shortly-frontend shortly-frontend

# Starts containers respecting depends_on
docker start shortly-redis
docker start shortly-backend  # waits for redis
docker start shortly-frontend # waits for backend
```

**6. Network Attachment:**
- Connects all containers to the default network
- Enables service discovery via DNS (backend, redis, frontend)

**In My Shortly Project:**
1. **Redis starts first** (no dependencies)
2. **Backend starts second** (depends on Redis)
3. **Frontend starts last** (depends on backend for API calls)
4. **Nginx configured separately** (reverse proxy for production)

**Dependency Resolution:**
```yaml
services:
  frontend:
    depends_on:
      - backend
  backend:
    depends_on:
      - redis
```

---

### Q19: How do you handle container orchestration at scale?

**Your Experience:** "My single EC2 deployment works for learning, but for enterprise scale..."

**Technical Answer:**
Container orchestration at scale requires moving beyond Docker Compose:

**Current Limitations (Single Host):**
- **Single point of failure:** One EC2 instance hosts everything
- **Resource constraints:** Limited CPU/memory on single machine
- **Manual scaling:** No automatic response to load changes
- **No load balancing:** Single backend instance handles all requests

**Enterprise Orchestration Solutions:**

**1. Kubernetes (Industry Standard):**
```yaml
# Deployment for automatic scaling
apiVersion: apps/v1
kind: Deployment
metadata:
  name: shortly-backend
spec:
  replicas: 3  # Multiple instances
  selector:
    matchLabels:
      app: backend
  template:
    spec:
      containers:
      - name: backend
        image: shortly-backend:latest
        resources:
          requests:
            memory: "256Mi"
            cpu: "250m"
          limits:
            memory: "512Mi" 
            cpu: "500m"
```

**2. Docker Swarm (Docker Native):**
```bash
# Initialize swarm cluster
docker swarm init

# Deploy stack across multiple nodes
docker stack deploy -c docker-compose.yml shortly

# Scale services dynamically
docker service scale shortly_backend=5
```

**3. AWS ECS (Managed Container Service):**
- **Task definitions:** Container specifications
- **Services:** Manage desired count and load balancing
- **Clusters:** Groups of EC2 instances or Fargate
- **Auto Scaling:** Based on CPU/memory metrics

**Key Orchestration Features Needed:**
- **Service Discovery:** Automatic endpoint resolution
- **Load Balancing:** Distribute traffic across instances  
- **Health Monitoring:** Replace failed containers automatically
- **Rolling Updates:** Zero-downtime deployments
- **Resource Management:** CPU/memory allocation and limits
- **Secret Management:** Secure handling of credentials

**Bridge to Kubernetes:** "My Docker Compose experience provides the foundation, but Kubernetes adds enterprise-grade orchestration, scaling, and management capabilities."

---

### Q20: What security considerations are important for containerized applications?

**Your Experience:** "In my production Shortly deployment, I implemented several security layers..."

**Technical Answer:**
Container security requires defense-in-depth strategy:

**1. Image Security:**
```dockerfile
# Use minimal, trusted base images
FROM python:3.11-alpine

# Create non-root user
RUN addgroup -g 1001 -S appgroup && \
    adduser -S appuser -u 1001 -G appgroup

# Switch to non-root user
USER appuser

# Avoid running as root
EXPOSE 8000
```

**2. Runtime Security:**
```yaml
# docker-compose.yml security settings
services:
  backend:
    security_opt:
      - no-new-privileges:true
    read_only: true
    tmpfs:
      - /tmp
    cap_drop:
      - ALL
    cap_add:
      - NET_BIND_SERVICE
```

**3. Network Security:**
```bash
# UFW firewall rules (implemented in my project)
sudo ufw allow 22    # SSH only
sudo ufw allow 80    # HTTP
sudo ufw allow 443   # HTTPS
sudo ufw deny 3000   # Block direct frontend access
sudo ufw deny 8000   # Block direct backend access
```

**4. Secret Management:**
```yaml
# Environment-based secrets (current approach)
environment:
  - REDIS_PASSWORD=${REDIS_PASSWORD}
  - JWT_SECRET=${JWT_SECRET}

# Docker secrets (better approach)
secrets:
  redis_password:
    file: ./secrets/redis_password.txt
```

**5. SSL/TLS Implementation:**
- **Let's Encrypt certificates:** Automated SSL with Certbot
- **HTTPS enforcement:** Nginx redirects HTTP to HTTPS
- **HSTS headers:** Prevent protocol downgrade attacks
- **Strong cipher suites:** Modern TLS configuration

**6. Container Scanning:**
```bash
# Scan images for vulnerabilities
docker scout cves shortly-backend:latest

# Security benchmarks
docker bench for security
```

**Real Security Measures in My Project:**
- **Reverse proxy:** Nginx hides internal services
- **Firewall:** UFW blocks unnecessary ports  
- **SSL certificates:** Full HTTPS encryption
- **Non-root containers:** Limited privilege escalation
- **Regular updates:** Automated security patches

**Enterprise Additions Needed:**
- **Image scanning:** Vulnerability assessment in CI/CD
- **Runtime protection:** Falco for anomaly detection
- **Network policies:** Kubernetes network segmentation
- **Secret rotation:** Automated credential updates
- **Compliance scanning:** CIS benchmarks and standards

---

### Q21: How would you troubleshoot a container that keeps restarting?

**Your Experience:** "When I had the health check issue in my Shortly backend..."

**Technical Answer:**
Systematic approach to container restart troubleshooting:

**1. Check Container Status and History:**
```bash
# Container status
docker-compose ps
docker ps -a

# Restart history and exit codes
docker inspect shortly-backend | grep -A 5 "State"

# Container events
docker events --filter container=shortly-backend
```

**2. Examine Logs for Error Patterns:**
```bash
# Recent logs
docker-compose logs --tail=50 backend

# Follow logs in real-time
docker-compose logs -f backend

# System logs
journalctl -u docker.service
```

**3. Resource and Health Check Analysis:**
```bash
# Resource usage
docker stats shortly-backend

# Health check status
docker inspect shortly-backend | grep -A 10 "Health"

# Manual health check
curl -f http://localhost:8000/health
```

**4. Common Restart Causes and Solutions:**

**Memory Issues:**
```bash
# Check memory limits
docker inspect shortly-backend | grep -i memory

# Solution: Increase memory limits
deploy:
  resources:
    limits:
      memory: 1G
```

**Health Check Failures:**
```dockerfile
# My actual issue: Route conflicts
# Problem: Generic /{short_code} catching /health
@app.get("/{short_code}")  # This was catching everything
@app.get("/health")        # This never executed

# Solution: Reorder routes
@app.get("/health")        # Specific routes first
@app.get("/{short_code}")  # Generic routes last
```

**Application Startup Issues:**
```bash
# Check application logs
docker exec -it shortly-backend cat /var/log/app.log

# Test application directly
docker exec -it shortly-backend python -c "import app; print('OK')"
```

**Dependency Problems:**
```yaml
# Ensure proper startup order
depends_on:
  redis:
    condition: service_healthy

# Add health checks to dependencies
redis:
  healthcheck:
    test: ["CMD", "redis-cli", "ping"]
    interval: 5s
    timeout: 3s
    retries: 5
```

**5. My Real Troubleshooting Experience:**
- **Symptom:** Backend container showing "unhealthy" status
- **Investigation:** Health endpoint returning 500 errors
- **Root cause:** FastAPI route precedence issue
- **Solution:** Moved specific routes before generic patterns
- **Verification:** Health checks started passing consistently

**Prevention Strategies:**
- **Comprehensive testing:** Test all endpoints before deployment
- **Staged deployment:** Test in staging environment first
- **Monitoring:** Set up alerts for restart patterns
- **Documentation:** Record common issues and solutions

---

*This document will be continuously updated as learning progresses through Kubernetes and advanced DevOps topics.* 