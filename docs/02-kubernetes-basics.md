# 🚢 Kubernetes Fundamentals: From Containers to Orchestration

**Learning Objective:** Master Kubernetes core concepts and container orchestration to deploy the Shortly URL shortener application to AWS EKS, building on Docker containerization and Terraform infrastructure expertise.

---

## 📍 Navigation

**Current Location:** `/Learn_Docker_kubernetes/docs/02-kubernetes-basics.md`
**Project Context:** Shortly URL Shortener (FastAPI + React + Redis)
**Prerequisites:** Docker fundamentals, AWS basics, Terraform knowledge

---

## 🎯 Learning Objectives

By the end of this module, you will:

- **Understand Kubernetes architecture** and why it's essential for production
- **Master core Kubernetes objects** (Pods, Deployments, Services, ConfigMaps)
- **Design Kubernetes manifests** for the Shortly application
- **Understand container orchestration** concepts and patterns
- **Prepare for EKS deployment** with production-ready configurations
- **Bridge Docker Compose to Kubernetes** concepts seamlessly

---

## 💡 What is Kubernetes?

### **The Evolution: From Single Containers to Orchestration**

**Your Journey So Far:**
```
Phase 1: Docker Containers
├── Individual containers running locally
├── Docker Compose for multi-container apps
└── Manual container management

Phase 2: Cloud Infrastructure  
├── Single EC2 instance with Docker Compose
├── Manual scaling and management
└── Limited high availability

Phase 3: Infrastructure as Code
├── Terraform for automated provisioning
├── Reproducible infrastructure
└── Version-controlled configurations

Phase 4: Kubernetes Orchestration ← YOU ARE HERE
├── Automated container management at scale
├── Self-healing and auto-scaling
└── Enterprise-grade production deployment
```

### **What Problems Does Kubernetes Solve?**

**Docker Compose Limitations (What You've Experienced):**
- ✅ **Great for development** - Easy local multi-container setup
- ❌ **Single host only** - Can't span multiple servers
- ❌ **No auto-scaling** - Manual container scaling
- ❌ **No self-healing** - Crashed containers stay crashed
- ❌ **No load balancing** - Basic service discovery only
- ❌ **No rolling updates** - Downtime during deployments

**Kubernetes Solutions:**
- ✅ **Multi-host orchestration** - Containers across multiple servers
- ✅ **Automatic scaling** - Scale based on CPU, memory, custom metrics
- ✅ **Self-healing** - Automatic restart of failed containers
- ✅ **Built-in load balancing** - Traffic distribution across instances
- ✅ **Rolling updates** - Zero-downtime deployments
- ✅ **Service discovery** - Automatic DNS and service registration

### **Kubernetes in Simple Terms**

Think of Kubernetes as a **smart container manager** that:

```
Docker Compose (What You Know)    →    Kubernetes (What You're Learning)
┌─────────────────────────────┐        ┌─────────────────────────────┐
│  You: docker-compose up    │   →    │  K8s: Desired state defined │
│  You: Check if running      │   →    │  K8s: Continuously monitors │
│  You: Restart if crashed    │   →    │  K8s: Auto-heals problems   │
│  You: Scale manually        │   →    │  K8s: Auto-scales on demand │
│  You: Update with downtime  │   →    │  K8s: Rolling updates       │
└─────────────────────────────┘        └─────────────────────────────┘
```

---

## 🏗️ Kubernetes Architecture

### **The Big Picture**

```
┌─────────────────────────────────────────────────────────────────────┐
│                        Kubernetes Cluster                           │
│                                                                     │
│  ┌─────────────────────┐              ┌─────────────────────────┐   │
│  │    Control Plane    │              │      Worker Nodes       │   │
│  │   (Master Nodes)    │              │                         │   │
│  │                     │              │  ┌─────────────────┐   │   │
│  │  ┌───────────────┐  │              │  │     Node 1      │   │   │
│  │  │  API Server   │  │◄────────────►│  │  ┌───────────┐  │   │   │
│  │  └───────────────┘  │              │  │  │   Pods    │  │   │   │
│  │  ┌───────────────┐  │              │  │  └───────────┘  │   │   │
│  │  │     etcd      │  │              │  └─────────────────┘   │   │
│  │  └───────────────┘  │              │                         │   │
│  │  ┌───────────────┐  │              │  ┌─────────────────┐   │   │
│  │  │  Scheduler    │  │              │  │     Node 2      │   │   │
│  │  └───────────────┘  │              │  │  ┌───────────┐  │   │   │
│  │  ┌───────────────┐  │              │  │  │   Pods    │  │   │   │
│  │  │ Controller    │  │              │  │  └───────────┘  │   │   │
│  │  │   Manager     │  │              │  └─────────────────┘   │   │
│  │  └───────────────┘  │              └─────────────────────────┘   │
│  └─────────────────────┘                                           │
└─────────────────────────────────────────────────────────────────────┘
```

### **Control Plane Components (The Brain)**

**1. API Server**
- **What it does:** Central communication hub for all Kubernetes operations
- **Your interaction:** Every `kubectl` command talks to the API Server
- **Analogy:** Like a receptionist that handles all requests

**2. etcd**
- **What it does:** Distributed database that stores cluster state
- **Contains:** All configuration, secrets, and current state
- **Analogy:** Like the cluster's memory/database

**3. Scheduler**
- **What it does:** Decides which node should run each pod
- **Considers:** Resource requirements, constraints, affinity rules
- **Analogy:** Like a smart placement manager

**4. Controller Manager**
- **What it does:** Ensures actual state matches desired state
- **Examples:** ReplicaSet Controller, Deployment Controller
- **Analogy:** Like supervisors ensuring work gets done

### **Worker Node Components (The Muscle)**

**1. kubelet**
- **What it does:** Agent that runs on each node, manages pods
- **Responsibilities:** Pull images, start containers, report status
- **Analogy:** Like a local manager on each server

**2. Container Runtime**
- **What it does:** Actually runs the containers (Docker, containerd)
- **Your context:** Same Docker engine you've been using
- **Analogy:** The actual worker doing the job

**3. kube-proxy**
- **What it does:** Handles network routing and load balancing
- **Function:** Implements Kubernetes Services networking
- **Analogy:** Like a smart network router

---

## 📦 Core Kubernetes Objects

### **Understanding the Hierarchy**

```
Namespace (Logical grouping)
└── Deployment (Manages application lifecycle)
    └── ReplicaSet (Ensures desired number of pods)
        └── Pod (Running container instance)
            └── Container (Your actual application)
```

### **1. Pods - The Smallest Deployable Unit**

**What is a Pod?**
A Pod is a wrapper around one or more containers that share:
- **Network** (same IP address)
- **Storage** (shared volumes)
- **Lifecycle** (created/destroyed together)

**Pod vs Container:**
```
Docker Container (What You Know)    →    Kubernetes Pod
┌─────────────────────────────┐        ┌─────────────────────────────┐
│  Single container           │   →    │  One or more containers     │
│  Own network namespace      │   →    │  Shared network namespace   │
│  Own storage                │   →    │  Shared storage volumes     │
│  Manual management          │   →    │  Managed by Kubernetes      │
└─────────────────────────────┘        └─────────────────────────────┘
```

**Simple Pod Example:**
```yaml
# pod.yaml
apiVersion: v1
kind: Pod
metadata:
  name: shortly-backend-pod
  labels:
    app: shortly-backend
spec:
  containers:
  - name: backend
    image: shortly-backend:latest
    ports:
    - containerPort: 8000
    env:
    - name: REDIS_HOST
      value: "redis-service"
```

**Why Not Use Pods Directly?**
- Pods are **ephemeral** - they can be deleted and recreated
- No **self-healing** - if a pod crashes, it stays crashed
- No **scaling** - you'd have to manually create multiple pods
- **Solution:** Use higher-level objects like Deployments

### **2. Deployments - Application Lifecycle Management**

**What is a Deployment?**
A Deployment manages a set of identical pods, providing:
- **Declarative updates** - describe desired state
- **Rolling updates** - zero-downtime deployments
- **Rollback capability** - revert to previous versions
- **Scaling** - increase/decrease pod count

**Deployment for Shortly Backend:**
```yaml
# backend-deployment.yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: shortly-backend
  labels:
    app: shortly-backend
spec:
  replicas: 3  # Run 3 instances
  selector:
    matchLabels:
      app: shortly-backend
  template:
    metadata:
      labels:
        app: shortly-backend
    spec:
      containers:
      - name: backend
        image: shortly-backend:latest
        ports:
        - containerPort: 8000
        env:
        - name: REDIS_HOST
          value: "redis-service"
        resources:
          requests:
            memory: "256Mi"
            cpu: "250m"
          limits:
            memory: "512Mi"
            cpu: "500m"
        livenessProbe:
          httpGet:
            path: /health
            port: 8000
          initialDelaySeconds: 30
          periodSeconds: 10
        readinessProbe:
          httpGet:
            path: /health
            port: 8000
          initialDelaySeconds: 5
          periodSeconds: 5
```

**Key Deployment Concepts:**
- **replicas: 3** - Always maintain 3 running pods
- **selector** - How Deployment finds its pods
- **template** - Pod specification to create
- **resources** - CPU/memory requests and limits
- **probes** - Health checks for automatic healing

### **3. Services - Network Access and Load Balancing**

**What is a Service?**
A Service provides stable network access to a set of pods:
- **Stable IP address** - doesn't change when pods restart
- **DNS name** - other pods can find it by name
- **Load balancing** - distributes traffic across pods
- **Service discovery** - automatic registration

**Service Types:**

**ClusterIP (Internal Access):**
```yaml
# backend-service.yaml
apiVersion: v1
kind: Service
metadata:
  name: backend-service
spec:
  selector:
    app: shortly-backend
  ports:
  - protocol: TCP
    port: 8000        # Service port
    targetPort: 8000  # Container port
  type: ClusterIP     # Only accessible within cluster
```

**LoadBalancer (External Access):**
```yaml
# frontend-service.yaml
apiVersion: v1
kind: Service
metadata:
  name: frontend-service
spec:
  selector:
    app: shortly-frontend
  ports:
  - protocol: TCP
    port: 80
    targetPort: 80
  type: LoadBalancer  # Creates AWS ALB/NLB
```

**Service Discovery in Action:**
```python
# In your FastAPI backend
REDIS_HOST = os.getenv("REDIS_HOST", "redis-service")  # DNS name!
REDIS_PORT = int(os.getenv("REDIS_PORT", 6379))

# Kubernetes automatically resolves "redis-service" to the correct IP
```

### **4. ConfigMaps and Secrets - Configuration Management**

**ConfigMaps for Non-Sensitive Data:**
```yaml
# app-config.yaml
apiVersion: v1
kind: ConfigMap
metadata:
  name: shortly-config
data:
  REDIS_HOST: "redis-service"
  REDIS_PORT: "6379"
  REDIS_DB: "0"
  LOG_LEVEL: "INFO"
  BASE_URL: "https://shortly.example.com"
```

**Secrets for Sensitive Data:**
```yaml
# app-secrets.yaml
apiVersion: v1
kind: Secret
metadata:
  name: shortly-secrets
type: Opaque
data:
  REDIS_PASSWORD: <base64-encoded-password>
  JWT_SECRET: <base64-encoded-secret>
```

**Using ConfigMaps and Secrets in Deployments:**
```yaml
# backend-deployment.yaml (excerpt)
spec:
  template:
    spec:
      containers:
      - name: backend
        image: shortly-backend:latest
        envFrom:
        - configMapRef:
            name: shortly-config
        - secretRef:
            name: shortly-secrets
```

### **5. Persistent Volumes - Data Storage**

**PersistentVolumeClaim for Redis:**
```yaml
# redis-pvc.yaml
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: redis-data
spec:
  accessModes:
  - ReadWriteOnce
  resources:
    requests:
      storage: 10Gi
  storageClassName: gp2  # AWS EBS storage
```

**Using PVC in Redis Deployment:**
```yaml
# redis-deployment.yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: redis
spec:
  replicas: 1
  selector:
    matchLabels:
      app: redis
  template:
    metadata:
      labels:
        app: redis
    spec:
      containers:
      - name: redis
        image: redis:7-alpine
        ports:
        - containerPort: 6379
        volumeMounts:
        - name: redis-storage
          mountPath: /data
      volumes:
      - name: redis-storage
        persistentVolumeClaim:
          claimName: redis-data
```

---

## 🔄 From Docker Compose to Kubernetes

### **Mapping Your Shortly Application**

**Current Docker Compose (What You Have):**
```yaml
# docker-compose.yml
version: '3.8'
services:
  redis:
    image: redis:7-alpine
    ports:
      - "6379:6379"
    volumes:
      - redis_data:/data

  backend:
    build: ./backend
    ports:
      - "8000:8000"
    environment:
      - REDIS_HOST=redis
    depends_on:
      - redis

  frontend:
    build: ./frontend
    ports:
      - "3000:80"
    depends_on:
      - backend

volumes:
  redis_data:
```

**Kubernetes Equivalent (What You're Building):**

**1. Redis (Database Layer):**
```yaml
# redis-deployment.yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: redis
spec:
  replicas: 1
  selector:
    matchLabels:
      app: redis
  template:
    metadata:
      labels:
        app: redis
    spec:
      containers:
      - name: redis
        image: redis:7-alpine
        ports:
        - containerPort: 6379
        volumeMounts:
        - name: redis-storage
          mountPath: /data
      volumes:
      - name: redis-storage
        persistentVolumeClaim:
          claimName: redis-data

---
apiVersion: v1
kind: Service
metadata:
  name: redis-service
spec:
  selector:
    app: redis
  ports:
  - port: 6379
    targetPort: 6379
```

**2. Backend (API Layer):**
```yaml
# backend-deployment.yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: shortly-backend
spec:
  replicas: 3  # Scale to 3 instances!
  selector:
    matchLabels:
      app: shortly-backend
  template:
    metadata:
      labels:
        app: shortly-backend
    spec:
      containers:
      - name: backend
        image: your-account.dkr.ecr.us-west-1.amazonaws.com/shortly-backend:latest
        ports:
        - containerPort: 8000
        env:
        - name: REDIS_HOST
          value: "redis-service"  # Service discovery!

---
apiVersion: v1
kind: Service
metadata:
  name: backend-service
spec:
  selector:
    app: shortly-backend
  ports:
  - port: 8000
    targetPort: 8000
```

**3. Frontend (Web Layer):**
```yaml
# frontend-deployment.yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: shortly-frontend
spec:
  replicas: 2
  selector:
    matchLabels:
      app: shortly-frontend
  template:
    metadata:
      labels:
        app: shortly-frontend
    spec:
      containers:
      - name: frontend
        image: your-account.dkr.ecr.us-west-1.amazonaws.com/shortly-frontend:latest
        ports:
        - containerPort: 80

---
apiVersion: v1
kind: Service
metadata:
  name: frontend-service
spec:
  selector:
    app: shortly-frontend
  ports:
  - port: 80
    targetPort: 80
  type: LoadBalancer  # External access via AWS ALB
```

### **Key Differences and Improvements**

| **Aspect** | **Docker Compose** | **Kubernetes** |
|------------|-------------------|----------------|
| **Scaling** | Manual: `docker-compose up --scale backend=3` | Declarative: `replicas: 3` |
| **Service Discovery** | Container names: `redis` | DNS names: `redis-service` |
| **Health Checks** | Basic Docker health checks | Liveness, readiness, startup probes |
| **Load Balancing** | None (single container per service) | Automatic across all replicas |
| **Storage** | Docker volumes | PersistentVolumes with cloud storage |
| **External Access** | Port mapping: `3000:80` | LoadBalancer Service with ALB |
| **Configuration** | Environment variables | ConfigMaps and Secrets |
| **Updates** | Stop/start (downtime) | Rolling updates (zero downtime) |

---

## 🎯 Kubernetes Networking Concepts

### **Understanding Service Discovery**

**In Docker Compose (What You Know):**
```yaml
services:
  backend:
    environment:
      - REDIS_HOST=redis  # Container name
```

**In Kubernetes:**
```yaml
# Service creates DNS entry
apiVersion: v1
kind: Service
metadata:
  name: redis-service  # Creates DNS: redis-service.default.svc.cluster.local
spec:
  selector:
    app: redis

# Deployment uses service name
apiVersion: apps/v1
kind: Deployment
spec:
  template:
    spec:
      containers:
      - name: backend
        env:
        - name: REDIS_HOST
          value: "redis-service"  # DNS resolution!
```

### **Network Policies (Advanced)**

```yaml
# Only allow backend to access redis
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: redis-access
spec:
  podSelector:
    matchLabels:
      app: redis
  policyTypes:
  - Ingress
  ingress:
  - from:
    - podSelector:
        matchLabels:
          app: shortly-backend
    ports:
    - protocol: TCP
      port: 6379
```

---

## 🚀 Production-Ready Patterns

### **1. Health Checks and Observability**

```yaml
# Comprehensive health checking
spec:
  containers:
  - name: backend
    image: shortly-backend:latest
    ports:
    - containerPort: 8000
    
    # Liveness probe: Is the container healthy?
    livenessProbe:
      httpGet:
        path: /health
        port: 8000
      initialDelaySeconds: 30
      periodSeconds: 10
      timeoutSeconds: 5
      failureThreshold: 3
    
    # Readiness probe: Is the container ready to serve traffic?
    readinessProbe:
      httpGet:
        path: /health
        port: 8000
      initialDelaySeconds: 5
      periodSeconds: 5
      timeoutSeconds: 3
      failureThreshold: 3
    
    # Startup probe: For slow-starting containers
    startupProbe:
      httpGet:
        path: /health
        port: 8000
      initialDelaySeconds: 10
      periodSeconds: 10
      timeoutSeconds: 5
      failureThreshold: 30
```

### **2. Resource Management**

```yaml
# Resource requests and limits
spec:
  containers:
  - name: backend
    resources:
      requests:
        memory: "256Mi"  # Guaranteed memory
        cpu: "250m"      # Guaranteed CPU (0.25 cores)
      limits:
        memory: "512Mi"  # Maximum memory
        cpu: "500m"      # Maximum CPU (0.5 cores)
```

### **3. Security Context**

```yaml
# Security best practices
spec:
  securityContext:
    runAsNonRoot: true
    runAsUser: 1000
    fsGroup: 1000
  containers:
  - name: backend
    securityContext:
      allowPrivilegeEscalation: false
      readOnlyRootFilesystem: true
      capabilities:
        drop:
        - ALL
```

### **4. Rolling Updates**

```yaml
# Deployment strategy
spec:
  strategy:
    type: RollingUpdate
    rollingUpdate:
      maxUnavailable: 1      # Max pods down during update
      maxSurge: 1           # Max extra pods during update
  replicas: 3
```

---

## 🛠️ Hands-On Exercise: Plan Your Shortly Kubernetes Deployment

### **Exercise 1: Design Your Manifest Structure**

Based on your Docker Compose knowledge, plan the Kubernetes manifests for Shortly:

**Required Files:**
```
kubernetes/
├── namespace.yaml           # Logical grouping
├── redis/
│   ├── redis-pvc.yaml      # Persistent storage
│   ├── redis-deployment.yaml
│   └── redis-service.yaml
├── backend/
│   ├── backend-configmap.yaml
│   ├── backend-secrets.yaml
│   ├── backend-deployment.yaml
│   └── backend-service.yaml
├── frontend/
│   ├── frontend-deployment.yaml
│   └── frontend-service.yaml
└── ingress.yaml            # External access routing
```

### **Exercise 2: Resource Planning**

**Questions to Consider:**
1. **How many replicas** should each service have?
   - Redis: 1 (stateful, single instance)
   - Backend: 3 (stateless, can scale)
   - Frontend: 2 (stateless, can scale)

2. **What resource limits** are appropriate?
   - Based on your Docker experience, what CPU/memory does each container need?

3. **What environment variables** need to become ConfigMaps vs Secrets?
   - ConfigMaps: REDIS_HOST, LOG_LEVEL, BASE_URL
   - Secrets: REDIS_PASSWORD, JWT_SECRET

### **Exercise 3: Service Discovery Planning**

**Map your Docker Compose connections to Kubernetes Services:**
```
Docker Compose              →    Kubernetes Services
backend → redis             →    backend → redis-service
frontend → backend          →    frontend → backend-service
external → frontend         →    LoadBalancer → frontend-service
```

---

## ✅ Knowledge Check

Before proceeding to kubectl setup, ensure you understand:

### **Core Concepts:**
- [ ] **What is a Pod?** Smallest deployable unit, wraps containers
- [ ] **What is a Deployment?** Manages pod lifecycle, scaling, updates
- [ ] **What is a Service?** Provides stable network access to pods
- [ ] **What is a ConfigMap?** Non-sensitive configuration data
- [ ] **What is a Secret?** Sensitive configuration data

### **Docker Compose to Kubernetes Mapping:**
- [ ] **Container** → Pod (with additional orchestration)
- [ ] **Service** → Deployment + Service (separation of concerns)
- [ ] **Networks** → Services (automatic service discovery)
- [ ] **Volumes** → PersistentVolumes (cloud-native storage)
- [ ] **Environment** → ConfigMaps + Secrets (proper separation)

### **Production Concepts:**
- [ ] **Health Checks:** Liveness, readiness, startup probes
- [ ] **Resource Management:** Requests, limits, quality of service
- [ ] **Security:** Non-root users, read-only filesystems
- [ ] **Scaling:** Horizontal scaling with multiple replicas

---

## 🎯 Next Steps

**✅ Kubernetes Fundamentals Complete!**

You now understand:
- ✅ **Kubernetes architecture** and core components
- ✅ **Essential Kubernetes objects** and their relationships
- ✅ **How to map Docker Compose** to Kubernetes manifests
- ✅ **Production-ready patterns** for enterprise deployment

**🚀 Ready for Step 2:** Install and configure kubectl and local Kubernetes development environment

**Next Module:** We'll set up your development environment, install kubectl, and start creating actual Kubernetes manifests for your Shortly application.

---

## 📚 Additional Resources

- [Kubernetes Official Documentation](https://kubernetes.io/docs/)
- [Kubernetes Concepts](https://kubernetes.io/docs/concepts/)
- [kubectl Cheat Sheet](https://kubernetes.io/docs/reference/kubectl/cheatsheet/)
- [AWS EKS User Guide](https://docs.aws.amazon.com/eks/latest/userguide/)

---

**🎉 Congratulations!** You've mastered Kubernetes fundamentals and are ready to start hands-on implementation! The concepts you've learned here will directly apply to your EKS deployment of the Shortly application. 