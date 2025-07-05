# AWS Infrastructure: From Local to Cloud

**Learning Objective:** Deploy the Shortly URL shortener application from local Docker containers to AWS cloud infrastructure, mastering cloud fundamentals, security, and production deployment strategies.

---

## Table of Contents

1. [Cloud Computing Fundamentals](#cloud-computing-fundamentals)
2. [AWS Core Services Overview](#aws-core-services-overview)
3. [Project 4: EC2 "Lift and Shift" Deployment](#project-4-ec2-lift-and-shift-deployment)
4. [Project 5: Infrastructure as Code with Terraform](#project-5-infrastructure-as-code-with-terraform)
5. [Security Best Practices](#security-best-practices)
6. [Monitoring and Logging](#monitoring-and-logging)
7. [Troubleshooting Guide](#troubleshooting-guide)

---

## Cloud Computing Fundamentals

### What is Cloud Computing?

Cloud computing is the delivery of computing services—including servers, storage, databases, networking, software, analytics, and intelligence—over the Internet ("the cloud") to offer faster innovation, flexible resources, and economies of scale.

### Why Move from Local to Cloud?

**Local Development (What we've built):**
- ✅ Great for development and testing
- ✅ Full control over environment
- ❌ Limited to your machine's resources
- ❌ Not accessible from internet
- ❌ No built-in redundancy or scaling
- ❌ You manage all infrastructure

**Cloud Deployment (Where we're going):**
- ✅ Accessible from anywhere on internet
- ✅ Scalable resources on demand
- ✅ Built-in redundancy and availability
- ✅ Professional security and compliance
- ✅ Managed services reduce operational overhead
- ✅ Pay only for what you use

### Cloud Service Models

**1. Infrastructure as a Service (IaaS) - EC2**
- You manage: Applications, Data, Runtime, Middleware, OS
- Cloud manages: Virtualization, Servers, Storage, Networking
- **Example:** AWS EC2 instances - virtual servers in the cloud

**2. Platform as a Service (PaaS) - Elastic Beanstalk**
- You manage: Applications, Data
- Cloud manages: Runtime, Middleware, OS, Virtualization, Servers, Storage, Networking
- **Example:** AWS Elastic Beanstalk - just upload your code

**3. Software as a Service (SaaS) - Gmail**
- You manage: Data (your emails)
- Cloud manages: Everything else
- **Example:** Gmail, Office 365, Salesforce

**For Project 4:** We'll use **IaaS (EC2)** to understand cloud fundamentals before moving to more managed services.

---

## AWS Core Services Overview

### Amazon EC2 (Elastic Compute Cloud)

**What is EC2?**
EC2 provides resizable compute capacity in the cloud. Think of it as a virtual server that you can start, stop, and configure as needed.

**Key Concepts:**

**1. Instance Types**
- **t3.micro:** 1 vCPU, 1 GB RAM - Perfect for our Shortly app (Free Tier eligible)
- **t3.small:** 2 vCPU, 2 GB RAM - For higher traffic
- **m5.large:** 2 vCPU, 8 GB RAM - For production workloads

**2. Amazon Machine Images (AMIs)**
- Pre-configured templates for EC2 instances
- **Amazon Linux 2:** AWS-optimized, free, includes Docker support
- **Ubuntu 20.04 LTS:** Popular, well-documented, familiar

**3. Security Groups**
- Virtual firewalls that control traffic to your instances
- **Inbound Rules:** What traffic can reach your instance
- **Outbound Rules:** What traffic can leave your instance

**4. Key Pairs**
- Public-private key cryptography for secure SSH access
- AWS stores the public key, you keep the private key

### AWS Networking Basics

**1. Virtual Private Cloud (VPC)**
- Your own isolated network in AWS
- Default VPC is created automatically and works for most use cases

**2. Subnets**
- Subdivisions of your VPC
- **Public Subnet:** Has internet access (for web servers)
- **Private Subnet:** No direct internet access (for databases)

**3. Internet Gateway**
- Allows communication between your VPC and the internet

**4. Route Tables**
- Control where network traffic is directed

### AWS Security and Access Management

**1. IAM (Identity and Access Management)**
- **Users:** Individual people or services
- **Roles:** Permissions that can be assumed by AWS services
- **Policies:** Documents that define permissions

**2. Security Groups vs NACLs**
- **Security Groups:** Instance-level, stateful (return traffic automatically allowed)
- **NACLs:** Subnet-level, stateless (must explicitly allow return traffic)

---

## Project 4: EC2 "Lift and Shift" Deployment

### Overview

**Goal:** Deploy our complete Shortly URL shortener application to AWS EC2, making it accessible from the public internet.

**"Lift and Shift" Strategy:**
- Take our existing Docker Compose setup
- "Lift" it from local environment
- "Shift" it to cloud infrastructure
- Minimal changes to application code
- Focus on infrastructure and deployment

### Architecture Diagram

```
Internet
    ↓
[Route 53 DNS] → your-domain.com
    ↓
[Application Load Balancer] (Optional for this project)
    ↓
[Internet Gateway]
    ↓
[Public Subnet in VPC]
    ↓
[EC2 Instance - t3.micro]
├── [Security Group: HTTP/HTTPS/SSH]
├── [Docker Engine]
└── [Docker Compose]
    ├── [Redis Container] :6379
    ├── [FastAPI Backend] :8000
    └── [React Frontend] :3000 (Nginx)
```

### Prerequisites

**Before we start, you'll need:**

1. **AWS Account**
   - Sign up at https://aws.amazon.com
   - Free Tier includes 750 hours/month of t3.micro instances
   - Credit card required but won't be charged for Free Tier usage

2. **AWS CLI Installation**
   ```bash
   # Windows (PowerShell)
   winget install Amazon.AWSCLI
   
   # Verify installation
   aws --version
   ```

3. **Domain Name (Optional but Recommended)**
   - Purchase a cheap domain (~$10-15/year) from AWS Route 53 or external provider
   - We'll use this for professional HTTPS setup
   - Alternative: Use EC2 public IP for testing

### Phase 1: AWS Account Setup and CLI Configuration

**Step 1: Create AWS Account**
1. Go to https://aws.amazon.com and click "Create an AWS Account"
2. Follow the registration process
3. Verify your email and phone number
4. Add payment method (required but Free Tier won't charge)

**Step 2: Create IAM User for CLI Access**

**Why not use root account?**
- Root account has unlimited permissions
- Best practice: Create IAM user with only needed permissions
- Easier to manage and rotate credentials

**Create IAM User:**
1. Log into AWS Console
2. Navigate to IAM service
3. Click "Users" → "Add User"
4. Username: `shortly-deployer`
5. Access type: ✅ Programmatic access
6. Permissions: Attach existing policies directly
   - ✅ `AmazonEC2FullAccess`
   - ✅ `AmazonRoute53FullAccess` (if using custom domain)
7. Download the CSV with Access Key ID and Secret Access Key
8. **IMPORTANT:** Store these securely - you can't retrieve the secret key again

**Step 3: Configure AWS CLI**
```bash
# Configure AWS CLI with your credentials
aws configure

# You'll be prompted for:
# AWS Access Key ID: [Your Access Key from CSV]
# AWS Secret Access Key: [Your Secret Key from CSV]  
# Default region name: us-east-1
# Default output format: json
```

**Step 4: Verify Configuration**
```bash
# Test AWS CLI connection
aws sts get-caller-identity

# Expected output:
# {
#     "UserId": "AIDACKCEVSQ6C2EXAMPLE",
#     "Account": "123456789012", 
#     "Arn": "arn:aws:iam::123456789012:user/shortly-deployer"
# }
```

### Phase 2: Understanding AWS Security Groups

**What are Security Groups?**
Security Groups act as virtual firewalls for your EC2 instances. They control inbound and outbound traffic at the instance level.

**Key Characteristics:**
- **Stateful:** If you allow inbound traffic, the response is automatically allowed outbound
- **Deny by default:** All traffic is blocked unless explicitly allowed
- **Multiple rules:** You can have multiple inbound and outbound rules
- **Source/Destination:** Rules can specify IP addresses, IP ranges, or other security groups

**Security Group Rules for Shortly App:**

| Type | Protocol | Port Range | Source | Purpose |
|------|----------|------------|---------|---------|
| SSH | TCP | 22 | Your IP | Remote server management |
| HTTP | TCP | 80 | 0.0.0.0/0 | Web traffic (redirects to HTTPS) |
| HTTPS | TCP | 443 | 0.0.0.0/0 | Secure web traffic |
| Custom TCP | TCP | 3000 | 0.0.0.0/0 | React frontend (temporary) |

**Best Practices:**
- **Principle of Least Privilege:** Only open ports you actually need
- **Restrict SSH:** Only allow SSH from your IP address, not 0.0.0.0/0
- **Use HTTPS:** Always encrypt web traffic in production
- **Regular Reviews:** Periodically audit and clean up unused rules

### Phase 3: Launching Your First EC2 Instance

**Step 1: Choose AMI (Amazon Machine Image)**
```bash
# List available Amazon Linux 2 AMIs in us-east-1
aws ec2 describe-images \
  --owners amazon \
  --filters "Name=name,Values=amzn2-ami-hvm-*" \
          "Name=architecture,Values=x86_64" \
          "Name=state,Values=available" \
  --query 'Images | sort_by(@, &CreationDate) | [-1].ImageId' \
  --output text
```

**Step 2: Create Key Pair**
```bash
# Create a new key pair for SSH access
aws ec2 create-key-pair \
  --key-name shortly-key \
  --query 'KeyMaterial' \
  --output text > shortly-key.pem

# Set proper permissions (Linux/Mac/WSL)
chmod 400 shortly-key.pem

# Windows PowerShell alternative:
# icacls shortly-key.pem /inheritance:r /grant:r "%username%:R"
```

**Step 3: Create Security Group**
```bash
# Create security group
aws ec2 create-security-group \
  --group-name shortly-sg \
  --description "Security group for Shortly URL shortener app"

# Add SSH access (replace YOUR_IP with your actual IP)
aws ec2 authorize-security-group-ingress \
  --group-name shortly-sg \
  --protocol tcp \
  --port 22 \
  --cidr YOUR_IP/32

# Add HTTP access
aws ec2 authorize-security-group-ingress \
  --group-name shortly-sg \
  --protocol tcp \
  --port 80 \
  --cidr 0.0.0.0/0

# Add HTTPS access  
aws ec2 authorize-security-group-ingress \
  --group-name shortly-sg \
  --protocol tcp \
  --port 443 \
  --cidr 0.0.0.0/0

# Add React frontend access (temporary)
aws ec2 authorize-security-group-ingress \
  --group-name shortly-sg \
  --protocol tcp \
  --port 3000 \
  --cidr 0.0.0.0/0
```

**How to find your IP address:**
```bash
# Option 1: Use curl
curl ifconfig.me

# Option 2: Use AWS CLI
curl checkip.amazonaws.com

# Option 3: Google "what is my ip"
```

**Step 4: Launch EC2 Instance**
```bash
# Launch the instance
aws ec2 run-instances \
  --image-id ami-0abcdef1234567890 \
  --count 1 \
  --instance-type t3.micro \
  --key-name shortly-key \
  --security-groups shortly-sg \
  --tag-specifications 'ResourceType=instance,Tags=[{Key=Name,Value=shortly-app-server}]'
```

**Step 5: Get Instance Information**
```bash
# Get instance details
aws ec2 describe-instances \
  --filters "Name=tag:Name,Values=shortly-app-server" \
  --query 'Reservations[0].Instances[0].{InstanceId:InstanceId,State:State.Name,PublicIP:PublicIpAddress}'
```

**Step 6: Connect to Your Instance**
```bash
# SSH into your instance (replace PUBLIC_IP with actual IP)
ssh -i shortly-key.pem ec2-user@PUBLIC_IP

# First time connection will ask to verify fingerprint - type 'yes'
```

### Phase 4: Server Setup and Application Deployment

**Step 1: Update System and Install Docker**
```bash
# Update the system
sudo yum update -y

# Install Docker
sudo yum install -y docker

# Start Docker service
sudo systemctl start docker
sudo systemctl enable docker

# Add ec2-user to docker group (avoid using sudo)
sudo usermod -a -G docker ec2-user

# Log out and back in for group changes to take effect
exit
ssh -i shortly-key.pem ec2-user@PUBLIC_IP
```

**Step 2: Install Docker Compose**
```bash
# Download Docker Compose
sudo curl -L "https://github.com/docker/compose/releases/latest/download/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose

# Make it executable
sudo chmod +x /usr/local/bin/docker-compose

# Verify installation
docker --version
docker-compose --version
```

**Step 3: Transfer Application Files**

**Option A: Using Git (Recommended)**
```bash
# Clone your repository
git clone https://github.com/yourusername/Learn_Docker_kubernetes.git
cd Learn_Docker_kubernetes/shortly
```

**Option B: Using SCP (if no Git)**
```bash
# From your local machine, copy files to EC2
scp -i shortly-key.pem -r /path/to/Learn_Docker_kubernetes/shortly ec2-user@PUBLIC_IP:~/
```

**Step 4: Deploy the Application**
```bash
# Navigate to the shortly directory
cd ~/Learn_Docker_kubernetes/shortly

# Start the application
docker-compose up -d

# Check if containers are running
docker-compose ps

# View logs if there are issues
docker-compose logs
```

**Step 5: Test the Application**
```bash
# Test from the server
curl http://localhost:3000

# Test from your browser
# Open: http://PUBLIC_IP:3000
```

### Phase 5: Domain Setup and SSL Configuration

**Step 1: Domain Configuration (Optional)**

**If you have a domain:**
1. Go to your domain registrar's DNS settings
2. Create an A record pointing to your EC2 public IP:
   ```
   Name: shortly (or @)
   Type: A
   Value: YOUR_EC2_PUBLIC_IP
   TTL: 300
   ```

**Step 2: Install and Configure Nginx**
```bash
# Install Nginx
sudo yum install -y nginx

# Start and enable Nginx
sudo systemctl start nginx
sudo systemctl enable nginx
```

**Step 3: Configure Nginx as Reverse Proxy**
```bash
# Create Nginx configuration
sudo tee /etc/nginx/conf.d/shortly.conf << 'EOF'
server {
    listen 80;
    server_name your-domain.com;  # Replace with your domain or use _

    location / {
        proxy_pass http://localhost:3000;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
    }

    location /api {
        proxy_pass http://localhost:8000;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
    }
}
EOF

# Test Nginx configuration
sudo nginx -t

# Reload Nginx
sudo systemctl reload nginx
```

**Step 4: Install SSL Certificate with Let's Encrypt**
```bash
# Install Certbot
sudo yum install -y certbot python3-certbot-nginx

# Obtain SSL certificate (replace with your domain)
sudo certbot --nginx -d your-domain.com

# Test automatic renewal
sudo certbot renew --dry-run
```

### Phase 6: Production Hardening and Monitoring

**Step 1: Configure Firewall**
```bash
# Install and configure firewall
sudo yum install -y firewalld
sudo systemctl start firewalld
sudo systemctl enable firewalld

# Allow necessary ports
sudo firewall-cmd --permanent --add-service=ssh
sudo firewall-cmd --permanent --add-service=http
sudo firewall-cmd --permanent --add-service=https
sudo firewall-cmd --reload
```

**Step 2: Set Up Log Monitoring**
```bash
# Install CloudWatch agent (optional)
wget https://s3.amazonaws.com/amazoncloudwatch-agent/amazon_linux/amd64/latest/amazon-cloudwatch-agent.rpm
sudo rpm -U ./amazon-cloudwatch-agent.rpm

# Configure log rotation for Docker
sudo tee /etc/logrotate.d/docker << 'EOF'
/var/lib/docker/containers/*/*.log {
    rotate 7
    daily
    compress
    size=1M
    missingok
    delaycompress
    copytruncate
}
EOF
```

**Step 3: Set Up Backup Strategy**
```bash
# Create backup script for Redis data
sudo tee /usr/local/bin/backup-redis.sh << 'EOF'
#!/bin/bash
BACKUP_DIR="/home/ec2-user/backups"
DATE=$(date +%Y%m%d_%H%M%S)

mkdir -p $BACKUP_DIR

# Backup Redis data
docker exec shortly_redis_1 redis-cli BGSAVE
docker cp shortly_redis_1:/data/dump.rdb $BACKUP_DIR/redis-backup-$DATE.rdb

# Keep only last 7 days of backups
find $BACKUP_DIR -name "redis-backup-*.rdb" -mtime +7 -delete

echo "Backup completed: redis-backup-$DATE.rdb"
EOF

sudo chmod +x /usr/local/bin/backup-redis.sh

# Set up daily backup cron job
(crontab -l 2>/dev/null; echo "0 2 * * * /usr/local/bin/backup-redis.sh") | crontab -
```

### Phase 7: Testing and Verification

**Verification Checklist:**

**1. Application Functionality**
- [ ] Frontend loads at http://your-domain.com or http://PUBLIC_IP
- [ ] Can create shortened URLs
- [ ] Shortened URLs redirect correctly
- [ ] All API endpoints respond correctly

**2. Security Verification**
- [ ] SSH only accessible from your IP
- [ ] HTTP redirects to HTTPS (if SSL configured)
- [ ] Security group rules are minimal and necessary
- [ ] No unnecessary ports open

**3. Performance Testing**
```bash
# Test API performance
curl -w "@curl-format.txt" -o /dev/null -s http://your-domain.com/

# Create curl-format.txt
cat > curl-format.txt << 'EOF'
     time_namelookup:  %{time_namelookup}\n
        time_connect:  %{time_connect}\n
     time_appconnect:  %{time_appconnect}\n
    time_pretransfer:  %{time_pretransfer}\n
       time_redirect:  %{time_redirect}\n
  time_starttransfer:  %{time_starttransfer}\n
                     ----------\n
          time_total:  %{time_total}\n
EOF
```

**4. Monitoring Setup**
```bash
# Check system resources
htop
df -h
free -h

# Check Docker container health
docker-compose ps
docker stats

# Check application logs
docker-compose logs -f
```

### Common Issues and Troubleshooting

**Issue 1: Cannot connect to EC2 instance**
```bash
# Check security group allows SSH from your IP
aws ec2 describe-security-groups --group-names shortly-sg

# Verify your current IP
curl ifconfig.me

# Update security group if IP changed
aws ec2 authorize-security-group-ingress \
  --group-name shortly-sg \
  --protocol tcp \
  --port 22 \
  --cidr NEW_IP/32
```

**Issue 2: Application not accessible from internet**
```bash
# Check if containers are running
docker-compose ps

# Check port binding
netstat -tlnp | grep :3000

# Check security group allows HTTP/HTTPS
aws ec2 describe-security-groups --group-names shortly-sg
```

**Issue 3: SSL certificate issues**
```bash
# Check certificate status
sudo certbot certificates

# Renew certificate manually
sudo certbot renew

# Check Nginx configuration
sudo nginx -t
```

**Issue 4: High memory usage**
```bash
# Check container resource usage
docker stats

# Restart containers if needed
docker-compose restart

# Check system memory
free -h
```

---

## Security Best Practices

### Instance Security

**1. Regular Updates**
```bash
# Set up automatic security updates
sudo yum install -y yum-cron
sudo systemctl enable yum-cron
sudo systemctl start yum-cron
```

**2. SSH Hardening**
```bash
# Edit SSH configuration
sudo nano /etc/ssh/sshd_config

# Recommended changes:
# PermitRootLogin no
# PasswordAuthentication no
# PubkeyAuthentication yes
# Port 2222  # Change default port

sudo systemctl restart sshd
```

**3. Fail2Ban Setup**
```bash
# Install Fail2Ban
sudo yum install -y epel-release
sudo yum install -y fail2ban

# Configure Fail2Ban
sudo systemctl enable fail2ban
sudo systemctl start fail2ban
```

### Application Security

**1. Environment Variables**
```bash
# Use .env file for sensitive data
cat > .env << 'EOF'
REDIS_PASSWORD=your-secure-password
JWT_SECRET=your-jwt-secret
DATABASE_URL=redis://redis:6379
EOF

# Update docker-compose.yml to use .env
```

**2. Container Security**
```bash
# Run containers as non-root user
# Update Dockerfiles to include:
# USER 1000:1000

# Scan images for vulnerabilities
docker run --rm -v /var/run/docker.sock:/var/run/docker.sock \
  aquasec/trivy image shortly_backend
```

### Network Security

**1. VPC Configuration**
```bash
# Create custom VPC (advanced topic for later)
aws ec2 create-vpc --cidr-block 10.0.0.0/16
```

**2. Security Group Audit**
```bash
# List all security groups
aws ec2 describe-security-groups \
  --query 'SecurityGroups[*].{Name:GroupName,Rules:IpPermissions}'
```

---

## Cost Optimization

### Free Tier Limits

**EC2 Free Tier:**
- 750 hours per month of t2.micro or t3.micro instances
- 30 GB of EBS storage
- 15 GB of bandwidth out aggregated across all AWS services

**Monitoring Usage:**
```bash
# Check your Free Tier usage
aws ce get-dimension-values \
  --dimension Key \
  --time-period Start=2023-01-01,End=2023-12-31
```

### Cost-Saving Tips

**1. Instance Scheduling**
```bash
# Stop instance when not needed
aws ec2 stop-instances --instance-ids i-1234567890abcdef0

# Start instance when needed
aws ec2 start-instances --instance-ids i-1234567890abcdef0
```

**2. Elastic IP Considerations**
- Elastic IPs are free when attached to running instances
- Charged $0.005/hour when not attached or attached to stopped instances
- Consider using dynamic IPs for development

**3. Data Transfer Optimization**
- First 1 GB of data transfer out is free
- Use CloudFront CDN for static assets (15 GB free per month)

---

## Next Steps: Project 5 Preview

After successfully deploying to EC2, we'll move to **Project 5: Infrastructure as Code with Terraform**:

**What we'll learn:**
- Define infrastructure as code
- Version control your infrastructure
- Automated provisioning and teardown
- Multiple environment management
- Infrastructure testing and validation

**Benefits over manual deployment:**
- **Reproducible:** Same infrastructure every time
- **Version Controlled:** Track changes over time
- **Collaborative:** Team can work on infrastructure together
- **Automated:** No manual clicking in AWS console
- **Testable:** Validate infrastructure before deployment

---

## Summary

In Project 4, you've learned:

✅ **Cloud Computing Fundamentals** - Understanding IaaS, PaaS, SaaS models
✅ **AWS Core Services** - EC2, VPC, Security Groups, IAM basics  
✅ **Security Best Practices** - Principle of least privilege, SSH hardening
✅ **Production Deployment** - From local containers to public cloud
✅ **Domain and SSL Setup** - Professional HTTPS configuration
✅ **Monitoring and Logging** - Basic observability setup
✅ **Troubleshooting Skills** - Real-world problem solving

**Key DevOps Skills Gained:**
- Cloud infrastructure provisioning
- Security group configuration
- Production deployment strategies
- SSL/TLS certificate management
- Basic monitoring and alerting
- Cost optimization awareness

**Real-World Applications:**
- Deploy any containerized application to cloud
- Configure secure, production-ready infrastructure
- Set up professional domains with HTTPS
- Implement basic monitoring and backup strategies
- Troubleshoot common cloud deployment issues

You now have a production-ready URL shortener running on AWS that's accessible from anywhere in the world! 🚀 