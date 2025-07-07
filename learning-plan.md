# Learning Roadmap: Building a Full-Stack, Cloud-Native Application

**Core Principles:**
1.  **This document is our single source of truth.** It will be kept in context and updated continuously as we progress.
2.  **Plan before executing.** We will outline our steps here before writing code or running commands.
3.  **Documentation-first approach.** We create comprehensive, detailed documentation that teaches from scratch, assuming zero prior knowledge.
4.  **Concept + Hands-on.** Every tool and concept will be explained theoretically first, then immediately applied practically.
5.  **Absolute path clarity.** All file and directory references will specify exact paths to avoid confusion.
6.  **Update, don't append.** This document will be updated to reflect current status, not appended to, to avoid redundancy and maintain clarity.
7.  **Preserve detailed information.** When updating completed phases, maintain comprehensive details rather than summarizing into single bullets. Update with new information while preserving the learning journey and technical specifics.

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
│   ├── 08-interview-preparation.md
│   ├── 09-terraform-fundamentals.md
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

*   **Backend:** FastAPI (Python) - Handles the logic of creating short links and redirecting users.
*   **Frontend:** React (JavaScript) - Clean UI to input a long URL and get the shortened version.
*   **Database:** Redis - Fast, in-memory key-value store for mapping short codes to long URLs.

**Note:** The application code is kept intentionally simple to focus on mastering enterprise-grade DevOps tools and practices.

### **How the Shortly App Works:**

1. **User Flow:**
   - User enters a long URL in the React frontend
   - Frontend sends POST request to FastAPI backend `/shorten` endpoint
   - Backend generates a short code and stores the mapping in Redis
   - Backend returns the shortened URL
   - When someone visits the short URL, backend looks up the original URL in Redis and redirects

2. **Technical Architecture:**
   ```
   [React Frontend] → [FastAPI Backend] → [Redis Database]
        │                    │                   │
   - URL input form     - POST /shorten      - Key-value store
   - Display results    - GET /{short_code}  - short_code → long_url
   - Handle redirects   - URL validation     - Fast lookups
   ```

3. **API Endpoints:**
   - `POST /shorten` - Create a short URL from a long URL
   - `GET /{short_code}` - Redirect to the original URL
   - `GET /health` - Health check endpoint

---
## The Article: A Content Creation Plan

The process remains the same: for each project, we will frame the goal, collect code snippets and screenshots, and draft the corresponding section for our Medium article while the concepts are fresh.

---

## Progress Tracking

### ✅ **Phase 1: Full-Stack Containerization (Local Development) - COMPLETED**

**Status:** ✅ **ALL PROJECTS COMPLETED SUCCESSFULLY**

**Completed Projects:**
- [x] **Project 1: Backend API (FastAPI + Redis)** - Complete with tests and containerization
- [x] **Project 2: Frontend UI (React)** - Modern UI with comprehensive testing
- [x] **Project 3: Docker Compose Orchestration** - Multi-service local deployment

**Key Achievements:**
- Complete containerized URL shortener application
- Production-ready Docker configurations with security best practices
- Comprehensive documentation and troubleshooting guides
- Real-world DevOps problem-solving experience

---

### ✅ **Phase 2: AWS Cloud Deployment - COMPLETED**

**Status:** ✅ **SUCCESSFULLY DEPLOYED TO PRODUCTION**

**Completed Projects:**
- [x] **Project 4: EC2 "Lift and Shift" Deployment** - Live production application

**🎉 Production Application:**
- **Live URL:** https://shortly-somesh.duckdns.org
- **Infrastructure:** AWS EC2 with security groups and key pairs
- **Security:** SSL/TLS certificates, firewall configuration, reverse proxy
- **Domain:** DuckDNS integration with DNS resolution
- **Monitoring:** Health checks, automated backups, log rotation
- **Architecture:** Nginx → Docker Compose → Multi-container application

**Key DevOps Skills Mastered:**
- Cloud infrastructure provisioning and management
- Production deployment strategies and security hardening
- SSL certificate management and automation
- Reverse proxy configuration and load balancing
- System monitoring, logging, and backup strategies
- Real-world troubleshooting and problem-solving

**Updated Documentation:**
- [x] **03-aws-infrastructure.md** - Complete AWS deployment guide
- [x] **08-interview-preparation.md** - TCS DevOps Engineer interview preparation

---

### ✅ **Phase 3: Infrastructure as Code (Terraform) - COMPLETED**

**Status:** ✅ **TERRAFORM AUTOMATION SUCCESSFULLY IMPLEMENTED**

**Completed Projects:**
- [x] **Project 5: Infrastructure as Code (Terraform)** - Complete automation of AWS infrastructure

**🎉 Terraform Infrastructure Automation:**
- **Infrastructure as Code:** Complete Terraform configuration for AWS resources
- **Automated Provisioning:** EC2, Security Groups, Key Pairs, Elastic IP via `terraform apply`
- **State Management:** Terraform state tracking and resource lifecycle management
- **Version Control:** Infrastructure configurations stored in Git
- **Reproducible Deployments:** Identical infrastructure creation in 18 seconds
- **Complete Automation:** End-to-end deployment from infrastructure to running application

**Key DevOps Skills Mastered:**
- **Terraform Fundamentals:** HCL syntax, providers, resources, variables, outputs
- **AWS Provider:** EC2, Security Groups, Key Pairs, Elastic IP management
- **Infrastructure Automation:** Declarative infrastructure definition and management
- **State Management:** Understanding Terraform state files and resource tracking
- **Security Configuration:** Automated security group rules and SSH key management
- **User Data Scripts:** Automated server configuration and application deployment
- **Troubleshooting:** Infrastructure debugging and problem resolution

**Technical Achievements:**
- **Complete Terraform Project Structure:** main.tf, variables.tf, outputs.tf, user-data.sh
- **Automated Application Deployment:** Git clone, Docker Compose, container orchestration
- **Network Security:** Proper port configuration for SSH, HTTP, HTTPS, and application ports
- **Resource Tagging:** Consistent resource identification and management
- **Infrastructure Updates:** In-place security group modifications without downtime

**Updated Documentation:**
- [x] **09-terraform-fundamentals.md** - Complete Terraform learning guide
- [x] **10-terraform-interview-preparation.md** - Comprehensive IaC interview preparation
- [x] **03-aws-infrastructure.md** - Updated with Terraform automation procedures

---

## 🎯 **CURRENT STATUS: Phase 4 - Kubernetes Container Orchestration**

**✅ Completed:** Local containerization + AWS cloud deployment + Infrastructure as Code + Terraform automation
**🎯 Current Goal:** Kubernetes orchestration and enterprise-grade container management

---

### **🚀 Phase 4: Kubernetes & Container Orchestration - IN PROGRESS**

**🎯 Current Priority: Kubernetes Fundamentals and EKS Deployment**

*   **Project 6: Kubernetes Deployment (EKS) - CURRENT FOCUS**
    *   **Goal:** Deploy Shortly to production-grade Kubernetes cluster on AWS EKS
    *   **Learning Objectives:**
        - Kubernetes fundamentals and container orchestration concepts
        - AWS EKS managed service integration and cluster management
        - Container registry management with Amazon ECR
        - Kubernetes manifests and resource management (YAML configurations)
        - Auto-scaling, resource optimization, and production readiness
        - Kubernetes networking, services, and ingress controllers
    *   **Phase 4 Implementation Plan:**
        1.  **Kubernetes Fundamentals (Week 1):**
            - Learn core Kubernetes concepts: Pods, Deployments, Services, ConfigMaps
            - Install kubectl and set up local development environment
            - Create basic Kubernetes manifests for Shortly application
            - Understand Kubernetes networking and service discovery
        2.  **Container Registry Setup (Week 1):**
            - Set up Amazon ECR repositories for backend, frontend, and Redis
            - Build and tag Docker images with proper versioning
            - Push images to ECR and configure authentication
            - Implement image scanning and security policies
        3.  **EKS Cluster Provisioning (Week 2):**
            - Use Terraform to create EKS cluster with managed node groups
            - Configure VPC, subnets, and security groups for EKS
            - Set up IAM roles and policies for cluster access
            - Install and configure AWS Load Balancer Controller
        4.  **Application Deployment (Week 2):**
            - Deploy Shortly application to EKS using Kubernetes manifests
            - Configure persistent storage for Redis using EBS volumes
            - Set up ConfigMaps and Secrets for application configuration
            - Implement health checks (liveness, readiness, startup probes)
        5.  **Production Features (Week 3):**
            - Implement Horizontal Pod Autoscaler for automatic scaling
            - Configure resource requests and limits for optimal performance
            - Set up Ingress controller for external access and SSL termination
            - Implement rolling updates and deployment strategies
        6.  **Monitoring & Observability (Week 3):**
            - Deploy Prometheus for metrics collection
            - Set up Grafana for visualization dashboards
            - Configure centralized logging with AWS CloudWatch
            - Implement alerting and notification systems
    *   **Success Criteria:**
        - Shortly application running on EKS with high availability
        - Auto-scaling based on CPU/memory metrics
        - Production-grade monitoring and logging
        - SSL-terminated external access via ALB Ingress
        - Complete infrastructure automation with Terraform
    *   **Documentation:** Create `02-kubernetes-basics.md`, `11-kubernetes-interview-preparation.md`, and update `05-monitoring-logging.md`

*   **Project 7: CI/CD Pipeline (Jenkins) - FUTURE**
    *   **Goal:** Fully automated DevOps pipeline for Shortly application
    *   **Timeline:** After Kubernetes mastery (Phase 5)
    *   **Learning Objectives:**
        - CI/CD pipeline design and implementation
        - Jenkins configuration and pipeline as code
        - Automated testing and security scanning
        - GitOps workflow integration with Kubernetes
    *   **Pipeline Development:**
        1.  **Jenkins Setup:** Configure Jenkins with:
            - Docker and Kubernetes plugins
            - AWS integration for ECR and EKS
            - GitHub webhook automation
        2.  **Pipeline Stages:** Create Jenkinsfile with:
            - Source code checkout and validation
            - Automated testing (pytest, React tests)
            - Security scanning with Trivy
            - Docker image building and ECR push
            - Kubernetes deployment updates
            - Smoke testing and verification
        3.  **Advanced Features:** Implement:
            - Branch-based deployment strategies
            - Rollback capabilities
            - Notification systems
            - Performance testing integration
    *   **Documentation:** Create `04-cicd-pipelines.md`

---

## 🎯 **NEXT PHASE OPTIONS: Advanced DevOps Specialization**

### **Phase 4 Learning Path Options:**

**🎯 Option 1: Kubernetes Deployment (EKS) - RECOMMENDED**
- **Timeline:** 2-3 weeks
- **Skills:** Container orchestration, EKS, auto-scaling, production Kubernetes
- **Value:** Highest industry demand, natural progression from Docker
- **Outcome:** Shortly app running on production Kubernetes cluster

**🔄 Option 2: CI/CD Pipeline (Jenkins/GitHub Actions)**
- **Timeline:** 1-2 weeks  
- **Skills:** Automated testing, deployment pipelines, GitOps workflows
- **Value:** Development workflow automation, team collaboration
- **Outcome:** Fully automated development-to-production pipeline

**📊 Option 3: Monitoring & Observability**
- **Timeline:** 1-2 weeks
- **Skills:** Prometheus, Grafana, logging, alerting, production monitoring
- **Value:** Production operations and incident response
- **Outcome:** Complete observability stack for Shortly application

**⚡ Option 4: Quick CI/CD Win (GitHub Actions)**
- **Timeline:** 2-3 days
- **Skills:** GitHub Actions, automated testing, Docker builds
- **Value:** Immediate workflow improvement, quick victory
- **Outcome:** Automated testing and deployment on every commit

### **Recommended Learning Sequence:**
1. **Kubernetes (EKS)** - Core container orchestration skills
2. **CI/CD Pipeline** - Automated workflows and testing
3. **Monitoring & Observability** - Production operations

### **Key Questions for Phase 4:**
- Which advanced DevOps skill area interests you most?
- Do you prefer deep technical challenges (Kubernetes) or workflow automation (CI/CD)?
- Are you ready for enterprise-grade container orchestration?
- Would you like a quick win before tackling larger projects?

---

*This document serves as our single source of truth and will be updated continuously as we progress through each phase.*