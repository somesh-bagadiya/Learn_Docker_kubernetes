# Learning Roadmap: Building a Full-Stack, Cloud-Native Application

**Core Principles:**
1.  **This document is our single source of truth.** It will be kept in context and updated continuously as we progress.
2.  **Plan before executing.** We will outline our steps here before writing code or running commands.
3.  **Documentation-first approach.** We create comprehensive, detailed documentation that teaches from scratch, assuming zero prior knowledge.
4.  **Concept + Hands-on.** Every tool and concept will be explained theoretically first, then immediately applied practically.
5.  **Absolute path clarity.** All file and directory references will specify exact paths to avoid confusion.

---

## Project Structure Overview

**Repository Root:** `/Learn_Docker_kubernetes/`
**Project Root:** `/Learn_Docker_kubernetes/shortly/`
**Documentation Root:** `/Learn_Docker_kubernetes/docs/`

```
Learn_Docker_kubernetes/                    # Repository root
├── docs/                                   # Documentation root (separate from project)
│   ├── 00-prerequisites.md
│   ├── 01-docker-fundamentals.md
│   ├── 02-kubernetes-basics.md
│   ├── 03-aws-infrastructure.md
│   ├── 04-cicd-pipelines.md
│   ├── 05-monitoring-logging.md
│   ├── 06-troubleshooting.md
│   ├── 07-best-practices.md
│   └── README.md
├── shortly/                               # Project root
│   ├── backend/
│   │   ├── app/
│   │   │   └── main.py
│   │   ├── tests/
│   │   │   └── test_main.py
│   │   ├── Dockerfile
│   │   └── requirements.txt
│   ├── frontend/
│   │   ├── public/
│   │   ├── src/
│   │   ├── Dockerfile
│   │   └── package.json
│   ├── jenkins/
│   │   └── Jenkinsfile
│   ├── terraform/
│   │   ├── main.tf
│   │   ├── variables.tf
│   │   └── outputs.tf
│   └── docker-compose.yml
└── learning-plan.md                       # This file (repository root)
```

---

## Documentation Strategy

Instead of a single Medium article, we will create a comprehensive documentation suite that serves as a complete learning resource:

### **Documentation Structure:**
**Location:** `/Learn_Docker_kubernetes/docs/`

```
docs/
├── 00-prerequisites.md          # System setup, tool installation
├── 01-docker-fundamentals.md   # Docker concepts + hands-on
├── 02-kubernetes-basics.md     # K8s concepts + hands-on  
├── 03-aws-infrastructure.md    # Cloud concepts + hands-on
├── 04-cicd-pipelines.md        # CI/CD concepts + hands-on
├── 05-monitoring-logging.md    # Observability concepts + hands-on
├── 06-troubleshooting.md       # Debugging and problem-solving
├── 07-best-practices.md        # Enterprise patterns and standards
└── README.md                   # Complete learning path overview
```

### **Path References in Documentation:**
- All commands will specify working directory: `cd /Learn_Docker_kubernetes/shortly/backend`
- All file references will use absolute paths from repository root
- All Docker build contexts will specify exact paths
- All configuration files will reference correct relative paths

### **Documentation Principles:**
1.  **Assume Zero Knowledge:** Every concept explained from first principles
2.  **Theory + Practice:** Each section starts with "What is X?" then "How to use X?"
3.  **Step-by-Step:** Granular, copy-paste instructions with expected outputs
4.  **Troubleshooting:** Common issues and solutions for each step
5.  **Real-World Context:** Why each tool/practice matters in enterprise environments
6.  **Path Clarity:** Every command and file reference specifies exact location

### **Content Creation Process:**
For each project phase:
1.  **Concept Introduction:** Explain the "why" before the "how"
2.  **Hands-on Implementation:** Detailed, step-by-step instructions with exact paths
3.  **Verification Steps:** How to confirm everything is working
4.  **Common Issues:** Troubleshooting guide for typical problems
5.  **Enterprise Context:** How this applies in real-world scenarios

---

## Alignment with Industry Roles (e.g., DevOps Engineer)

This learning plan is not just an academic exercise; it is designed to directly map to the skills required for a modern DevOps or Kubernetes Engineer role. Based on a typical job description, here is how our project-based approach aligns with industry expectations:

*   **Core Requirement: Docker & Containerization**
    *   **JD Asks For:** `docker/podman`, management of `containerized applications`.
    *   **Our Plan Covers:** **Phase 1** is entirely dedicated to creating professional, secure, and multi-stage Docker images and running them with Docker Compose.

*   **Core Requirement: Kubernetes**
    *   **JD Asks For:** `Kubernetes`, `K3S`, `deploy scalable and secure Kubernetes-based infrastructure`.
    *   **Our Plan Covers:** In **Phase 2**, we deploy our full-stack application to **Amazon EKS**, a managed Kubernetes service. The `kubectl` commands, manifest files, and Helm charts we learn are the universal standard and are 100% applicable to any Kubernetes distribution, including K3S.

*   **Core Requirement: CI/CD & Automation**
    *   **JD Asks For:** `implement continuous integration and delivery processes`, `Automate deployment, scaling, and management`.
    *   **Our Plan Covers:** **Phase 3** is a deep dive into building a complete CI/CD pipeline with a `Jenkinsfile`. We automate everything from testing to deployment.

*   **Core Requirement: Infrastructure as Code (IaC)**
    *   **JD Asks For:** `Design, develop, and deploy... infrastructure`, `Develop scripts for automating routine tasks`.
    *   **Our Plan Covers:** We use **Terraform** in **Phase 2** to define and provision our entire AWS infrastructure (EC2, EKS, ECR) as code. This is a critical enterprise-level skill that goes beyond basic scripting.

*   **Core Requirement: Security**
    *   **JD Asks For:** `Conduct regular security audits`, `deploy... secure... infrastructure`.
    *   **Our Plan Covers:** We have a dedicated **Security Scan** stage in our Jenkins pipeline (**Phase 3**) to check for vulnerabilities before deployment, directly addressing this crucial requirement.

### **Areas Requiring Additional Coverage:**

Based on the job description, we need to enhance our plan to include:

*   **Monitoring & Logging** *(JD: "Monitor and review the system logs and detect issues in the Kubernetes cluster")*
    *   **Gap:** We need to add monitoring and logging setup.
    *   **Enhancement:** We'll add **Prometheus** for metrics collection and **Grafana** for visualization in Phase 2, plus centralized logging with **ELK Stack** or **AWS CloudWatch**.

*   **High Availability & Performance** *(JD: "Ensure the high availability of applications and services", "assess and optimize application performance")*
    *   **Gap:** We need to demonstrate scaling strategies and performance optimization.
    *   **Enhancement:** We'll add load testing, auto-scaling configurations, and performance monitoring to our Kubernetes deployment.

*   **Collaboration & Documentation** *(JD: "Collaborate with the development team", "Develop and maintain documentation")*
    *   **Gap:** We need to show how DevOps integrates with development workflows.
    *   **Enhancement:** We'll create comprehensive documentation templates and demonstrate how our CI/CD pipeline integrates with developer workflows (branch strategies, pull request automation).

*   **Troubleshooting & Issue Resolution** *(JD: "Resolve technical issues related to the Kubernetes infrastructure")*
    *   **Gap:** We need hands-on troubleshooting experience.
    *   **Enhancement:** We'll intentionally break things and practice debugging techniques, including reading logs, using `kubectl` for troubleshooting, and implementing health checks.

*   **System Administration** *(JD: "Unix/Linux, Shell Scripting")*
    *   **Gap:** We need more Linux/shell scripting practice.
    *   **Enhancement:** We'll write shell scripts for automation tasks and ensure all our work is done primarily via command line.

---

Our goal is to mirror a real-world enterprise project. We will build a **URL Shortener** application (FastAPI backend, React frontend, Redis database), containerize it, and deploy it to AWS, first on a traditional server and then to a managed Kubernetes cluster. We will automate the entire process with a professional CI/CD pipeline using Jenkins and Infrastructure as Code with Terraform.

---

## The Planned Directory Structure

A clean, organized folder structure is the foundation of a professional project. Here is the structure we will build. This plan will be updated as we add new configuration files.

```
shortly/
├── backend/
│   ├── app/
│   │   └── main.py
│   ├── tests/
│   │   └── test_main.py
│   ├── Dockerfile
│   └── requirements.txt
│
├── frontend/
│   ├── public/
│   ├── src/
│   ├── Dockerfile
│   └── package.json
│
├── jenkins/
│   └── Jenkinsfile
│
├── terraform/
│   ├── main.tf
│   ├── variables.tf
│   └── outputs.tf
│
└── docker-compose.yml
```

---
## The Application: "Shortly" - A URL Shortener

*   **Backend:** FastAPI (Python) - Will handle the logic of creating short links and redirecting users.
*   **Frontend:** React (JavaScript) - A simple, clean UI to input a long URL and get the shortened version.
*   **Database:** Redis - A fast, in-memory key-value store perfect for mapping short codes to long URLs.

**Note:** The application code itself (FastAPI and React) will be kept intentionally simple. They serve as the "cargo" for our main learning objective: mastering the enterprise-grade DevOps tools and practices required to ship and maintain software in the cloud.

### **How the Shortly App Works:**

1. **User Flow:**
   - User enters a long URL (e.g., `https://example.com/very/long/path`) in the React frontend
   - Frontend sends a POST request to FastAPI backend `/shorten` endpoint
   - Backend generates a short code (e.g., `abc123`) and stores the mapping in Redis
   - Backend returns the shortened URL (e.g., `https://shortly.com/abc123`)
   - When someone visits the short URL, backend looks up the original URL in Redis and redirects

2. **Technical Architecture:**
   ```
   [React Frontend] → [FastAPI Backend] → [Redis Database]
        │                    │                   │
        │                    │                   │
   - URL input form     - POST /shorten      - Key-value store
   - Display results    - GET /{short_code}  - short_code → long_url
   - Handle redirects   - URL validation     - Fast lookups
   ```

3. **API Endpoints We'll Build:**
   - `POST /shorten` - Create a short URL from a long URL
   - `GET /{short_code}` - Redirect to the original URL
   - `GET /` - Health check endpoint
   - `GET /stats/{short_code}` - (Optional) Get click statistics

4. **Database Schema:**
   ```
   Redis Key-Value Pairs:
   "abc123" → "https://example.com/very/long/path"
   "def456" → "https://another-example.com/path"
   ```

---
## The Article: A Content Creation Plan

The process remains the same: for each project, we will frame the goal, collect code snippets and screenshots, and draft the corresponding section for our Medium article while the concepts are fresh.

---

## Progress Tracking

### ✅ **Completed Tasks**
- [x] **Learning Plan Setup** - Created comprehensive roadmap with absolute path clarity
- [x] **Documentation Structure** - Established `/Learn_Docker_kubernetes/docs/` with clear organization
- [x] **Project 1 (Backend API)** - ✅ COMPLETED
  - [x] FastAPI application with all endpoints (`/`, `/shorten`, `/{short_code}`)
  - [x] Redis integration for URL storage and retrieval
  - [x] Comprehensive test suite with pytest (100% coverage)
  - [x] Production-ready multi-stage Dockerfile with security best practices
  - [x] Error handling and validation
  - [x] Environment variable configuration
- [x] **Docker Deep Dive Documentation** - Created comprehensive Docker guide (`00-docker-deep-dive.md`)
- [x] **Project 2 (Frontend UI)** - ✅ COMPLETED
  - [x] React application with modern UI components
  - [x] URL input form with validation and error handling  
  - [x] API communication with FastAPI backend
  - [x] Results display with copy-to-clipboard functionality
  - [x] Comprehensive test suite with React Testing Library
  - [x] Production-ready multi-stage Dockerfile with Nginx
  - [x] ESLint configuration for code quality
- [x] **Project 3 (Docker Compose Orchestration)** - ✅ COMPLETED
  - [x] Multi-service Docker Compose configuration
  - [x] Service discovery and networking setup
  - [x] Environment variable management
  - [x] Data persistence with Redis volumes
  - [x] Dependency management (redis → backend → frontend)
  - [x] Production troubleshooting and debugging
  - [x] End-to-end integration testing
- [x] **Documentation Updates** - ✅ COMPLETED
  - [x] Updated `01-docker-fundamentals.md` with complete project details
  - [x] Enhanced `00-docker-deep-dive.md` with real-world troubleshooting
  - [x] Documented all production issues and solutions
  - [x] Added Docker Compose orchestration patterns

### 🎉 **Phase 1 Complete: Full-Stack Containerization (Local Development)**

**Status:** ✅ **ALL PROJECTS COMPLETED SUCCESSFULLY**

**What We Accomplished:**
- Built a complete URL shortener application (Shortly)
- Containerized all components (FastAPI, React, Redis)
- Implemented production-ready Docker configurations
- Mastered Docker Compose orchestration
- Solved real-world container deployment issues
- Created comprehensive documentation for enterprise use

**Key DevOps Skills Demonstrated:**
- Container debugging and troubleshooting
- Multi-stage Docker builds with security best practices
- Service discovery and networking
- Configuration management with environment variables
- Progressive problem-solving methodologies
- Production readiness patterns

**Complete Project Structure:**
```
/Learn_Docker_kubernetes/
├── docs/
│   ├── README.md                    ✅ Documentation overview
│   ├── 00-docker-deep-dive.md      ✅ Comprehensive Docker guide with troubleshooting
│   └── 01-docker-fundamentals.md   ✅ Complete containerization guide with all projects
├── shortly/
│   ├── backend/
│   │   ├── app/
│   │   │   └── main.py             ✅ Complete FastAPI application
│   │   ├── tests/
│   │   │   └── test_main.py        ✅ Full test suite (100% coverage)
│   │   ├── Dockerfile              ✅ Multi-stage production Dockerfile
│   │   └── requirements.txt        ✅ Pinned dependencies
│   ├── frontend/
│   │   ├── public/
│   │   │   └── index.html          ✅ HTML template with modern styling
│   │   ├── src/
│   │   │   ├── components/
│   │   │   │   ├── UrlShortener.js ✅ Main component with full functionality
│   │   │   │   ├── UrlShortener.css ✅ Modern responsive styling
│   │   │   │   └── UrlShortener.test.js ✅ Component tests
│   │   │   ├── App.js              ✅ Main App component
│   │   │   ├── App.css             ✅ App styling
│   │   │   ├── App.test.js         ✅ App tests
│   │   │   └── index.js            ✅ React entry point
│   │   ├── Dockerfile              ✅ Multi-stage production Dockerfile
│   │   ├── nginx.conf              ✅ Simplified Nginx configuration
│   │   ├── package.json            ✅ Dependencies and scripts
│   │   ├── .eslintrc.js            ✅ Code quality configuration
│   │   └── .dockerignore           ✅ Build optimization
│   └── docker-compose.yml          ✅ Complete orchestration configuration
└── learning-plan.md                ✅ This tracking document
```

---

## The Projects: A Hands-On Journey

### **✅ Phase 1: Full-Stack Containerization (Local Development) - COMPLETED**

*   **✅ Project 1: The Backend API (FastAPI + Redis) - COMPLETED**
    *   **Goal:** Build and containerize the core API service for the Shortly URL shortener.
    *   **✅ Application Development - COMPLETED:**
        1.  ✅ **Health Check Endpoint:** `GET /` endpoint returns "Shortly Backend is running!"
        2.  ✅ **URL Shortening Logic:** `POST /shorten` endpoint:
            - Accepts a long URL in the request body
            - Generates a random short code (6-character alphanumeric)
            - Stores the mapping in Redis (short_code → long_url)
            - Returns the shortened URL
        3.  ✅ **URL Redirect Logic:** `GET /{short_code}` endpoint:
            - Looks up the short code in Redis
            - Returns a redirect response to the original URL
            - Handles cases where short code doesn't exist
        4.  ✅ **Redis Integration:** Connected FastAPI to Redis for data storage and retrieval
        5.  ✅ **Testing:** Complete unit tests for all endpoints using `pytest` (100% coverage)
    *   **✅ Containerization - COMPLETED:** Multi-stage `Dockerfile` with security best practices
    *   **✅ Documentation - COMPLETED:** Added to `01-docker-fundamentals.md`

*   **✅ Project 2: The Frontend UI (React) - COMPLETED**
    *   **Goal:** Build and containerize the user-facing web application for the Shortly URL shortener.
    *   **✅ Application Development - COMPLETED:**
        1.  ✅ **URL Input Form:** React component with:
            - Text input field for long URLs with validation
            - Submit button to shorten the URL with loading states
            - Form validation and error messaging
        2.  ✅ **API Communication:** Implemented functions to:
            - Send POST requests to `/shorten` endpoint
            - Handle success and error responses gracefully
            - Display the shortened URL to the user
        3.  ✅ **Results Display:** Show the shortened URL with:
            - Copy-to-clipboard functionality with visual feedback
            - Test button to open redirect in new tab
            - Modern glassmorphism UI design
        4.  ✅ **Error Handling:** Handle network errors and invalid URLs gracefully
    *   **✅ Containerization - COMPLETED:** Multi-stage `Dockerfile` using Nginx with security best practices
    *   **✅ Documentation - COMPLETED:** Added to `01-docker-fundamentals.md`

*   **✅ Project 3: Local Orchestration (Docker Compose) - COMPLETED**
    *   **Goal:** Run the complete Shortly URL shortener application locally.
    *   **✅ Application Integration - COMPLETED:**
        1.  ✅ **Service Networking:** Configured Docker Compose to connect:
            - React frontend (port 3000) → FastAPI backend (port 8000)
            - FastAPI backend → Redis database (port 6379)
        2.  ✅ **Environment Configuration:** Set up environment variables for:
            - Redis connection parameters (REDIS_HOST, REDIS_PORT, REDIS_DB)
            - API base URL for frontend
            - CORS settings for cross-origin requests
        3.  ✅ **Data Persistence:** Configured Redis volume for data persistence
        4.  ✅ **End-to-End Testing:** Verified the complete flow:
            - Enter URL in React frontend ✅
            - Create short URL via FastAPI backend ✅
            - Test redirect functionality ✅
            - Verify data is stored in Redis ✅
        5.  ✅ **Production Troubleshooting:** Solved real-world issues:
            - Nginx permission errors with non-root users ✅
            - Docker build cache corruption ✅
            - Complex regex configuration failures ✅
            - Service discovery and environment variable mismatches ✅
    *   **✅ Documentation - COMPLETED:** Complete guide in `01-docker-fundamentals.md`

**🎉 Phase 1 Achievement Summary:**
- **Complete containerized application** running locally
- **Production-ready configurations** with security best practices
- **Comprehensive documentation** with troubleshooting guides
- **Real-world DevOps skills** demonstrated through problem-solving
- **Enterprise-grade patterns** implemented and documented

---

---

## 🚀 **CURRENT STATUS: Ready for Phase 2 - Cloud Deployment**

**✅ Phase 1 Complete:** Full-stack containerized application running locally
**🎯 Next Goal:** Deploy to public cloud and scale with enterprise tools

---

### **🌐 Phase 2: From Localhost to the Public Cloud (AWS)**

*   **🎯 Project 4: "Lift and Shift" Deployment (EC2 + Docker Compose)**
    *   **Goal:** Deploy the complete Shortly URL shortener application to the public internet.
    *   **Learning Objectives:**
        - AWS EC2 fundamentals and security groups
        - Public cloud networking concepts
        - Domain management and DNS configuration
        - Production deployment strategies
        - Cloud security best practices
    *   **Cloud Deployment Tasks:**
        1.  **Provision AWS EC2:** Launch a virtual server on AWS with appropriate security groups
        2.  **Configure Security:** Set up firewall rules to allow:
            - HTTP/HTTPS traffic (ports 80/443) for the React frontend
            - SSH access (port 22) for server management
        3.  **Deploy Shortly App:** 
            - SSH into the EC2 instance
            - Install Docker and Docker Compose
            - Copy our Shortly project files to the server
            - Run `docker-compose up -d` to start all services
            - Configure domain/subdomain to point to the server
        4.  **Test End-to-End:** Verify the Shortly app works from the internet:
            - Access the React frontend via public IP/domain
            - Create shortened URLs and test redirects
            - Confirm Redis data persistence
        5.  **Production Hardening:** Implement security best practices:
            - Configure SSL/TLS certificates
            - Set up monitoring and logging
            - Implement backup strategies
    *   **Documentation:** `03-aws-infrastructure.md` - "Deploying the Shortly URL Shortener to AWS EC2"

*   **🎯 Project 5: Infrastructure as Code (Terraform)**
    *   **Goal:** Automate the AWS infrastructure provisioning for the Shortly application.
    *   **Learning Objectives:**
        - Infrastructure as Code (IaC) principles
        - Terraform fundamentals and best practices
        - AWS resource management via code
        - Version-controlled infrastructure
        - Automated provisioning and teardown
    *   **Infrastructure Automation Tasks:**
        1.  **Define Infrastructure:** Write Terraform scripts to create:
            - EC2 instance with appropriate size and AMI
            - Security groups with correct port configurations
            - Key pairs for SSH access
            - Elastic IP for consistent public IP address
        2.  **Automate Deployment:** Create scripts to:
            - Provision infrastructure with `terraform apply`
            - Deploy the Shortly app automatically
            - Tear down everything with `terraform destroy`
        3.  **Version Control:** Store all infrastructure code in Git
        4.  **Documentation:** Create deployment runbooks and troubleshooting guides
        5.  **Advanced Patterns:** Implement:
            - Terraform modules for reusability
            - State management and remote backends
            - Environment-specific configurations
    *   **Documentation:** `03-aws-infrastructure.md` - "Automating Shortly App Infrastructure with Terraform"

*   **🎯 Project 6: Managed Kubernetes on AWS (EKS)**
    *   **Goal:** Deploy the Shortly URL shortener to a scalable, production-grade Kubernetes cluster.
    *   **Learning Objectives:**
        - Kubernetes fundamentals and container orchestration
        - AWS EKS managed service and IAM integration
        - Container registry management (ECR)
        - Kubernetes manifests and resource management
        - Auto-scaling and resource optimization
        - Production monitoring and observability
    *   **Kubernetes Deployment Tasks:**
        1.  **Provision EKS Cluster:** Use Terraform to create:
            - Amazon EKS cluster with worker nodes
            - Amazon ECR repositories for our container images
            - IAM roles and policies for secure access
        2.  **Prepare Container Images:** 
            - Build and tag Shortly app images (backend, frontend)
            - Push images to Amazon ECR
            - Update image references in Kubernetes manifests
        3.  **Deploy to Kubernetes:** Create and apply:
            - Deployment manifests for FastAPI backend and React frontend
            - Service manifests for internal communication
            - Ingress controller for external access
            - ConfigMaps for environment variables
            - Secrets for sensitive data (Redis passwords, etc.)
        4.  **Configure Scaling:** Set up:
            - Horizontal Pod Autoscaler for automatic scaling
            - Resource requests and limits for optimal performance
            - Health checks (liveness and readiness probes)
        5.  **Add Monitoring:** Deploy:
            - Prometheus for metrics collection
            - Grafana for visualization dashboards
            - AWS CloudWatch for centralized logging
        6.  **Test Production Readiness:** Verify:
            - Shortly app works under load
            - Auto-scaling triggers correctly
            - Monitoring alerts function properly
            - Logs are centralized and searchable
    *   **Documentation:** `02-kubernetes-basics.md` + `05-monitoring-logging.md` - "Running Shortly on Production Kubernetes with Monitoring"

---

### **Phase 3: End-to-End Automation (Jenkins CI/CD)**

*   **Project 7: The Cloud-Native CI/CD Pipeline**
    *   **Goal:** Create a fully automated pipeline that builds, tests, and deploys the Shortly URL shortener to EKS.
    *   **CI/CD Pipeline Development:**
        1.  **Setup Jenkins:** 
            - Launch Jenkins on a dedicated EC2 instance
            - Install necessary plugins (Docker, Kubernetes, AWS)
            - Configure AWS IAM permissions for ECR and EKS access
            - Set up GitHub webhook for automatic triggers
        2.  **Create the `Jenkinsfile`:** Write a declarative pipeline with stages:
            - **Source:** Check out Shortly app code from Git repository
            - **Test Backend:** Run `pytest` tests for FastAPI endpoints
            - **Test Frontend:** Run React component tests and linting
            - **Security Scan:** Use tools like `Trivy` to scan for vulnerabilities
            - **Build Images:** Build Docker images for FastAPI backend and React frontend
            - **Push to ECR:** Tag and push images to Amazon ECR
            - **Deploy to EKS:** Update Kubernetes deployments with new image versions
            - **Smoke Test:** Verify Shortly app endpoints are responding correctly
            - **Performance Test:** Run basic load tests against the deployed application
            - **Monitoring Check:** Confirm Prometheus is collecting metrics and Grafana dashboards are updating
        3.  **Branch Strategy:** Configure different pipeline behaviors:
            - `main` branch: Full pipeline with deployment to production EKS
            - `develop` branch: Run tests and build images, deploy to staging environment
            - Feature branches: Run tests only, no deployment
        4.  **Notification Setup:** Configure alerts for:
            - Pipeline failures via email/Slack
            - Successful deployments
            - Security scan findings
        5.  **Troubleshooting Lab:** Practice debugging by:
            - Intentionally breaking the Shortly app code
            - Introducing infrastructure issues
            - Simulating deployment failures
            - Using `kubectl`, logs, and monitoring to diagnose problems
    *   **Documentation:** `04-cicd-pipelines.md` - "Automating Shortly App Deployment with Jenkins CI/CD"

*   **Project 8: Advanced Operations & Maintenance**
    *   **Goal:** Demonstrate advanced operational skills for maintaining the Shortly URL shortener in production.
    *   **Production Operations:**
        1.  **Shell Scripting:** Create automation scripts for:
            - Database backup and restore procedures for Redis
            - Log rotation and cleanup for Shortly app containers
            - Health check scripts that verify all Shortly endpoints
            - Automated scaling based on URL creation rate
        2.  **Disaster Recovery:** Implement and test:
            - Redis data backup to S3 with scheduled snapshots
            - Full application restore procedures
            - Database failover scenarios
            - Cross-region deployment strategies
        3.  **Performance Optimization:** Use monitoring data to:
            - Identify slow API endpoints in the Shortly app
            - Optimize Redis queries and connection pooling
            - Tune Kubernetes resource requests and limits
            - Implement caching strategies for frequently accessed URLs
        4.  **Security Hardening:** Implement:
            - Network policies to restrict pod-to-pod communication
            - Pod security policies for the Shortly app containers
            - Secrets management for Redis passwords and API keys
            - Regular security scanning and vulnerability remediation
        5.  **Operational Documentation:** Create:
            - Runbooks for common Shortly app issues
            - Troubleshooting guides for deployment problems
            - Performance tuning playbooks
            - Security incident response procedures
        6.  **Chaos Engineering:** Practice resilience by:
            - Randomly terminating Shortly app pods
            - Simulating Redis failures
            - Testing behavior under high load
            - Validating monitoring and alerting systems
    *   **Documentation:** `06-troubleshooting.md` + `07-best-practices.md` - "Production Operations for the Shortly URL Shortener"

---

## 🎯 **IMMEDIATE NEXT STEPS**

### **Phase 2 Kickoff: Cloud Deployment**

**🎯 Current Priority: Project 4 - AWS EC2 "Lift and Shift" Deployment**

**Learning Focus:**
- Transition from local development to public cloud
- AWS fundamentals and security concepts
- Production deployment strategies
- Cloud networking and domain management

**Recommended Approach:**
1. **Start with AWS EC2 Setup** - Learn cloud fundamentals before automation
2. **Manual deployment first** - Understand the process before automating
3. **Document everything** - Capture real-world issues and solutions
4. **Progressive complexity** - EC2 → Terraform → Kubernetes

**Preparation Tasks:**
- [ ] Set up AWS account and configure CLI credentials
- [ ] Review AWS EC2 and security group concepts
- [ ] Plan domain/subdomain for public access
- [ ] Create `03-aws-infrastructure.md` documentation structure

**Success Criteria for Project 4:**
- Shortly app accessible from public internet
- All services running on AWS EC2 instance
- Domain pointing to the application
- SSL/TLS certificates configured
- Basic monitoring and logging in place
- Complete troubleshooting documentation

**Teaching Methodology:**
- **Theory First:** Explain AWS concepts before hands-on
- **Step-by-Step:** Detailed instructions with expected outputs
- **Real-World Context:** Why each step matters in enterprise environments
- **Problem-Solving:** Document and solve actual deployment issues
- **Verification:** Multiple ways to confirm everything is working

**Key Questions to Explore:**
- How does cloud networking differ from local Docker networking?
- What security considerations are unique to public cloud deployment?
- How do we manage secrets and environment variables in the cloud?
- What monitoring is essential for production applications?
- How do we troubleshoot issues in a cloud environment?