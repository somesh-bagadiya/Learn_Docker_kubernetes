# Shortly Kubernetes Manifests

This directory contains Kubernetes manifests for deploying the Shortly URL shortener application to AWS EKS.

## 📁 Directory Structure

```
kubernetes/
├── namespace.yaml                    # Namespace for resource organization
├── redis/
│   ├── redis-pvc.yaml               # Persistent storage for Redis
│   ├── redis-deployment.yaml        # Redis database deployment
│   └── redis-service.yaml           # Redis internal service
├── backend/
│   ├── backend-configmap.yaml       # Non-sensitive configuration
│   ├── backend-secrets.yaml         # Sensitive configuration
│   ├── backend-deployment.yaml      # FastAPI backend deployment
│   └── backend-service.yaml         # Backend internal service
├── frontend/
│   ├── frontend-deployment.yaml     # React frontend deployment
│   └── frontend-service.yaml        # Frontend external service
├── ingress.yaml                     # ALB Ingress for routing
├── kustomization.yaml               # Kustomize configuration
└── README.md                        # This file
```

## 🏗️ Architecture Overview

```
Internet → ALB Ingress → Frontend Service → Frontend Pods (2 replicas)
                    ↓
                    Backend Service → Backend Pods (3 replicas)
                                 ↓
                                 Redis Service → Redis Pod (1 replica)
                                            ↓
                                            EBS Volume (10Gi)
```

## 🚀 Deployment Instructions

### Prerequisites
- AWS EKS cluster running
- kubectl configured for your cluster
- AWS Load Balancer Controller installed
- ECR repositories created with images pushed

### Deploy Application
```bash
# Deploy all resources
kubectl apply -k .

# Or deploy individually
kubectl apply -f namespace.yaml
kubectl apply -f redis/
kubectl apply -f backend/
kubectl apply -f frontend/
kubectl apply -f ingress.yaml
```

### Verify Deployment
```bash
# Check all resources
kubectl get all -n shortly

# Check pods
kubectl get pods -n shortly

# Check services
kubectl get svc -n shortly

# Check ingress
kubectl get ingress -n shortly
```

## 📋 Resource Summary

| Resource | Replicas | CPU Request | Memory Request | Storage |
|----------|----------|-------------|----------------|---------|
| Redis | 1 | 250m | 256Mi | 10Gi EBS |
| Backend | 3 | 250m | 256Mi | - |
| Frontend | 2 | 100m | 128Mi | - |

## 🔧 Configuration

### Environment Variables (ConfigMap)
- `REDIS_HOST`: Redis service name
- `REDIS_PORT`: Redis port (6379)
- `LOG_LEVEL`: Application log level
- `BASE_URL`: Application base URL

### Secrets
- `JWT_SECRET`: JWT signing secret
- `API_KEY`: API authentication key
- `REDIS_PASSWORD`: Redis password (if enabled)

### Image References
Update these in deployment files:
- Backend: `YOUR_ACCOUNT.dkr.ecr.us-west-1.amazonaws.com/shortly-backend:latest`
- Frontend: `YOUR_ACCOUNT.dkr.ecr.us-west-1.amazonaws.com/shortly-frontend:latest`

## 🔍 Monitoring & Health Checks

### Health Endpoints
- Backend: `GET /health`
- Frontend: `GET /` (nginx default page)
- Redis: TCP socket check on port 6379

### Probe Configuration
- **Liveness**: Detects if container is healthy
- **Readiness**: Detects if container is ready for traffic
- **Startup**: Handles slow-starting containers

## 🛠️ Troubleshooting

### Common Commands
```bash
# Check pod logs
kubectl logs -n shortly -l app=shortly-backend

# Describe pod issues
kubectl describe pod -n shortly <pod-name>

# Check service endpoints
kubectl get endpoints -n shortly

# Port forward for testing
kubectl port-forward -n shortly svc/backend-service 8000:8000
```

### Common Issues
1. **ImagePullBackOff**: Check ECR image URLs and authentication
2. **CrashLoopBackOff**: Check application logs and health checks
3. **Service not accessible**: Verify service selectors and port configuration

## 📚 Next Steps

1. **ECR Setup**: Push Docker images to Amazon ECR
2. **EKS Cluster**: Create EKS cluster with Terraform
3. **Load Balancer Controller**: Install AWS Load Balancer Controller
4. **Deploy Application**: Apply these manifests to your cluster
5. **Configure Ingress**: Update domain and SSL certificate ARN

## 🔗 Related Documentation

- [Kubernetes Fundamentals](../docs/02-kubernetes-basics.md)
- [AWS EKS Setup](../docs/03-aws-infrastructure.md)
- [Docker Images](../backend/README.md) and [Frontend](../frontend/README.md) 