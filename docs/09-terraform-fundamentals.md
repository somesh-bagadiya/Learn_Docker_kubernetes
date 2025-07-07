# Terraform Fundamentals: Infrastructure as Code

**Learning Context:** Phase 3 of Shortly URL Shortener DevOps Journey  
**Previous Phase:** AWS EC2 Manual Deployment (https://shortly-somesh.duckdns.org)  
**Current Goal:** Automate infrastructure provisioning with Terraform  
**Project Root:** `/Learn_Docker_kubernetes/shortly/terraform/`

---

## Table of Contents

1. [What is Infrastructure as Code (IaC)?](#what-is-infrastructure-as-code-iac)
2. [Why Terraform?](#why-terraform)
3. [Terraform Core Concepts](#terraform-core-concepts)
4. [AWS Provider Fundamentals](#aws-provider-fundamentals)
5. [Terraform Workflow](#terraform-workflow)
6. [Project Structure & Best Practices](#project-structure--best-practices)
7. [Shortly App Infrastructure Requirements](#shortly-app-infrastructure-requirements)
8. [Hands-on Implementation Guide](#hands-on-implementation-guide)
9. [Advanced Terraform Concepts](#advanced-terraform-concepts)
10. [Troubleshooting & Common Issues](#troubleshooting--common-issues)

---

## What is Infrastructure as Code (IaC)?

### **Definition**
Infrastructure as Code (IaC) is the practice of managing and provisioning computing infrastructure through machine-readable definition files, rather than physical hardware configuration or interactive configuration tools.

### **Key Principles**

1. **Declarative Configuration**
   - Define the desired end state, not the steps to get there
   - Terraform figures out how to achieve that state
   - Example: "I want an EC2 instance with these specifications"

2. **Version Control**
   - Infrastructure definitions stored in Git
   - Track changes, collaborate, and rollback if needed
   - Treat infrastructure like application code

3. **Repeatability**
   - Same configuration produces identical infrastructure
   - Eliminate "works on my machine" problems
   - Consistent environments across dev/staging/production

4. **Automation**
   - Remove manual steps and human error
   - Integrate with CI/CD pipelines
   - Enable rapid scaling and disaster recovery

### **Benefits for Our Shortly App**

**Current Manual Process (What We Did in Phase 2):**
```bash
# Manual AWS Console clicks or CLI commands
aws ec2 create-security-group --group-name shortly-sg --description "Shortly app security group"
aws ec2 authorize-security-group-ingress --group-name shortly-sg --protocol tcp --port 22 --cidr 0.0.0.0/0
aws ec2 authorize-security-group-ingress --group-name shortly-sg --protocol tcp --port 80 --cidr 0.0.0.0/0
aws ec2 authorize-security-group-ingress --group-name shortly-sg --protocol tcp --port 443 --cidr 0.0.0.0/0
aws ec2 create-key-pair --key-name shortly-key --query 'KeyMaterial' --output text > shortly-key.pem
aws ec2 run-instances --image-id ami-0fa9de2bba4d18c53 --count 1 --instance-type t3.micro --key-name shortly-key --security-groups shortly-sg
```

**IaC Approach (What We'll Build):**
```hcl
# terraform/main.tf
resource "aws_security_group" "shortly_sg" {
  name        = "shortly-sg"
  description = "Shortly app security group"
  
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  
  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

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

---

## Why Terraform?

### **Terraform vs. Alternatives**

| Feature | Terraform | AWS CloudFormation | Ansible | Pulumi |
|---------|-----------|-------------------|---------|---------|
| **Multi-Cloud** | ✅ 3000+ providers | ❌ AWS only | ✅ Limited | ✅ Yes |
| **Learning Curve** | Moderate | Steep | Moderate | Steep |
| **State Management** | ✅ Built-in | ✅ Built-in | ❌ Limited | ✅ Built-in |
| **Language** | HCL (HashiCorp) | JSON/YAML | YAML | Real languages |
| **Community** | ✅ Large | ✅ Large | ✅ Large | 🔄 Growing |
| **Enterprise Support** | ✅ Terraform Cloud | ✅ AWS Support | ✅ Red Hat | ✅ Pulumi Cloud |

### **Why Terraform for Our Project**

1. **Industry Standard:** Most DevOps job postings mention Terraform
2. **AWS Integration:** Excellent AWS provider with comprehensive resource support
3. **Learning Value:** Skills transfer to other cloud providers
4. **Community:** Large ecosystem of modules and examples
5. **Career Relevance:** High demand skill in enterprise environments

---

## Terraform Core Concepts

### **1. Providers**
Plugins that enable Terraform to interact with APIs (AWS, Azure, Google Cloud, etc.)

```hcl
# Configure AWS Provider
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = "us-west-1"  # Our Shortly app region
}
```

### **2. Resources**
The fundamental building blocks - represent infrastructure components

```hcl
# EC2 Instance Resource
resource "aws_instance" "shortly_server" {
  ami           = "ami-0fa9de2bba4d18c53"
  instance_type = "t3.micro"
  
  # Resource attributes
  key_name = aws_key_pair.shortly_key.key_name
  
  tags = {
    Name = "shortly-server"
  }
}
```

### **3. Data Sources**
Query existing infrastructure or external data

```hcl
# Get latest Ubuntu AMI
data "aws_ami" "ubuntu" {
  most_recent = true
  owners      = ["099720109477"] # Canonical
  
  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-*"]
  }
}

# Use in resource
resource "aws_instance" "shortly_server" {
  ami = data.aws_ami.ubuntu.id
  # ... other configuration
}
```

### **4. Variables**
Input parameters for reusable configurations

```hcl
# variables.tf
variable "instance_type" {
  description = "EC2 instance type"
  type        = string
  default     = "t3.micro"
}

variable "key_name" {
  description = "AWS key pair name"
  type        = string
}

# Use in resource
resource "aws_instance" "shortly_server" {
  instance_type = var.instance_type
  key_name      = var.key_name
}
```

### **5. Outputs**
Return values from Terraform configurations

```hcl
# outputs.tf
output "instance_public_ip" {
  description = "Public IP address of the Shortly server"
  value       = aws_instance.shortly_server.public_ip
}

output "instance_public_dns" {
  description = "Public DNS name of the Shortly server"
  value       = aws_instance.shortly_server.public_dns
}
```

### **6. State**
Terraform's memory of what it has created

```json
{
  "version": 4,
  "terraform_version": "1.6.0",
  "serial": 1,
  "lineage": "12345678-1234-1234-1234-123456789012",
  "outputs": {
    "instance_public_ip": {
      "value": "13.57.241.79",
      "type": "string"
    }
  },
  "resources": [
    {
      "mode": "managed",
      "type": "aws_instance",
      "name": "shortly_server",
      "provider": "provider[\"registry.terraform.io/hashicorp/aws\"]",
      "instances": [
        {
          "schema_version": 1,
          "attributes": {
            "ami": "ami-0fa9de2bba4d18c53",
            "instance_type": "t3.micro",
            "public_ip": "13.57.241.79"
          }
        }
      ]
    }
  ]
}
```

---

## AWS Provider Fundamentals

### **Authentication Methods**

1. **AWS CLI Profile (Recommended for Development)**
   ```bash
   # Already configured in our setup
   aws configure list
   ```

2. **Environment Variables**
   ```bash
   export AWS_ACCESS_KEY_ID="your-access-key"
   export AWS_SECRET_ACCESS_KEY="your-secret-key"
   export AWS_DEFAULT_REGION="us-west-1"
   ```

3. **IAM Roles (Production)**
   ```hcl
   provider "aws" {
     region = "us-west-1"
     assume_role {
       role_arn = "arn:aws:iam::123456789012:role/TerraformRole"
     }
   }
   ```

### **Common AWS Resources for Our Project**

```hcl
# Security Group
resource "aws_security_group" "shortly_sg" {
  name        = "shortly-sg"
  description = "Security group for Shortly application"
  
  # SSH access
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  
  # HTTP access
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  
  # HTTPS access
  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  
  # All outbound traffic
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# Key Pair
resource "aws_key_pair" "shortly_key" {
  key_name   = "shortly-key"
  public_key = file("~/.ssh/shortly-key.pub")
}

# EC2 Instance
resource "aws_instance" "shortly_server" {
  ami           = data.aws_ami.ubuntu.id
  instance_type = var.instance_type
  key_name      = aws_key_pair.shortly_key.key_name
  
  vpc_security_group_ids = [aws_security_group.shortly_sg.id]
  
  # User data script for initial setup
  user_data = file("${path.module}/user-data.sh")
  
  tags = {
    Name        = "shortly-server"
    Project     = "DevOps-Learning"
    Environment = "production"
  }
}

# Elastic IP (Optional)
resource "aws_eip" "shortly_eip" {
  instance = aws_instance.shortly_server.id
  domain   = "vpc"
  
  tags = {
    Name = "shortly-eip"
  }
}
```

---

## Terraform Workflow

### **The Terraform Lifecycle**

```
┌─────────────────┐    ┌─────────────────┐    ┌─────────────────┐
│                 │    │                 │    │                 │
│  terraform init │───▶│ terraform plan  │───▶│ terraform apply │
│                 │    │                 │    │                 │
└─────────────────┘    └─────────────────┘    └─────────────────┘
         │                       │                       │
         │                       │                       │
         ▼                       ▼                       ▼
┌─────────────────┐    ┌─────────────────┐    ┌─────────────────┐
│   Download      │    │   Show planned  │    │   Execute       │
│   providers     │    │   changes       │    │   changes       │
│   Initialize    │    │   Validate      │    │   Update state  │
│   backend       │    │   configuration │    │   Create/modify │
└─────────────────┘    └─────────────────┘    └─────────────────┘
```

### **1. terraform init**
```bash
cd /Learn_Docker_kubernetes/shortly/terraform
terraform init
```

**What it does:**
- Downloads required providers (AWS)
- Initializes the backend (state storage)
- Prepares the working directory

**Expected output:**
```
Initializing the backend...

Initializing provider plugins...
- Finding hashicorp/aws versions matching "~> 5.0"...
- Installing hashicorp/aws v5.31.0...
- Installed hashicorp/aws v5.31.0 (signed by HashiCorp)

Terraform has been successfully initialized!
```

### **2. terraform plan**
```bash
terraform plan
```

**What it does:**
- Compares current state with desired state
- Shows what changes will be made
- Validates configuration syntax
- **NEVER** makes actual changes

**Expected output:**
```
Terraform used the selected providers to generate the following execution plan.
Resource actions are indicated with the following symbols:
  + create

Terraform will perform the following actions:

  # aws_instance.shortly_server will be created
  + resource "aws_instance" "shortly_server" {
      + ami                                  = "ami-0fa9de2bba4d18c53"
      + instance_type                        = "t3.micro"
      + key_name                             = "shortly-key"
      + public_ip                            = (known after apply)
      + vpc_security_group_ids               = (known after apply)
      # ... more attributes
    }

Plan: 1 to add, 0 to change, 0 to destroy.
```

### **3. terraform apply**
```bash
terraform apply
```

**What it does:**
- Shows the plan again
- Asks for confirmation (type "yes")
- Executes the planned changes
- Updates the state file

**Expected output:**
```
Do you want to perform these actions?
  Terraform will perform the actions described above.
  Only 'yes' will be accepted to approve.

  Enter a value: yes

aws_instance.shortly_server: Creating...
aws_instance.shortly_server: Still creating... [10s elapsed]
aws_instance.shortly_server: Still creating... [20s elapsed]
aws_instance.shortly_server: Creation complete after 23s [id=i-0123456789abcdef0]

Apply complete! Resources: 1 added, 0 changed, 0 destroyed.

Outputs:

instance_public_ip = "13.57.241.79"
```

### **4. terraform destroy**
```bash
terraform destroy
```

**What it does:**
- Shows destruction plan
- Asks for confirmation
- Destroys all managed resources
- Updates state to reflect destruction

---

## Project Structure & Best Practices

### **Directory Structure**
```
/Learn_Docker_kubernetes/shortly/terraform/
├── main.tf                 # Main configuration
├── variables.tf            # Input variables
├── outputs.tf              # Output values
├── terraform.tfvars        # Variable values (gitignored)
├── terraform.tfvars.example # Example variable file
├── user-data.sh            # EC2 initialization script
├── .gitignore              # Ignore sensitive files
└── README.md               # Terraform documentation
```

### **File Organization Best Practices**

**main.tf** - Core resources
```hcl
# Provider configuration
terraform {
  required_version = ">= 1.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = var.aws_region
}

# Data sources
data "aws_ami" "ubuntu" {
  most_recent = true
  owners      = ["099720109477"]
  
  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-*"]
  }
}

# Resources
resource "aws_security_group" "shortly_sg" {
  # ... configuration
}

resource "aws_key_pair" "shortly_key" {
  # ... configuration
}

resource "aws_instance" "shortly_server" {
  # ... configuration
}
```

**variables.tf** - Input definitions
```hcl
variable "aws_region" {
  description = "AWS region for resources"
  type        = string
  default     = "us-west-1"
}

variable "instance_type" {
  description = "EC2 instance type"
  type        = string
  default     = "t3.micro"
}

variable "key_name" {
  description = "AWS key pair name"
  type        = string
}

variable "allowed_ssh_cidr" {
  description = "CIDR blocks allowed for SSH access"
  type        = list(string)
  default     = ["0.0.0.0/0"]
}
```

**outputs.tf** - Return values
```hcl
output "instance_id" {
  description = "ID of the EC2 instance"
  value       = aws_instance.shortly_server.id
}

output "instance_public_ip" {
  description = "Public IP address of the EC2 instance"
  value       = aws_instance.shortly_server.public_ip
}

output "instance_public_dns" {
  description = "Public DNS name of the EC2 instance"
  value       = aws_instance.shortly_server.public_dns
}

output "security_group_id" {
  description = "ID of the security group"
  value       = aws_security_group.shortly_sg.id
}
```

**terraform.tfvars** - Variable values (keep private)
```hcl
aws_region    = "us-west-1"
instance_type = "t3.micro"
key_name      = "shortly-key"
```

**.gitignore** - Protect sensitive files
```
# Terraform files
*.tfstate
*.tfstate.*
*.tfvars
.terraform/
.terraform.lock.hcl
crash.log
crash.*.log

# SSH keys
*.pem
*.ppk
```

---

## Shortly App Infrastructure Requirements

### **Current Manual Infrastructure (Phase 2)**

From our successful AWS deployment, we need to recreate:

1. **EC2 Instance**
   - AMI: `ami-0fa9de2bba4d18c53` (Ubuntu 22.04 LTS)
   - Instance Type: `t3.micro`
   - Region: `us-west-1`
   - Availability Zone: `us-west-1a`

2. **Security Group**
   - Name: `shortly-sg`
   - SSH (22): `0.0.0.0/0`
   - HTTP (80): `0.0.0.0/0`
   - HTTPS (443): `0.0.0.0/0`
   - All outbound traffic

3. **Key Pair**
   - Name: `shortly-key`
   - Public key from existing pair

4. **Application Setup**
   - Docker and Docker Compose installation
   - Shortly project deployment
   - Nginx reverse proxy configuration
   - SSL certificate setup

### **Terraform Implementation Strategy**

**Phase 1: Basic Infrastructure**
- Recreate EC2, Security Group, Key Pair
- Verify basic connectivity

**Phase 2: Application Deployment**
- User data script for Docker installation
- Automated Shortly app deployment
- Basic health checks

**Phase 3: Advanced Features**
- Elastic IP for static addressing
- CloudWatch monitoring
- Automated backups
- Multiple environment support

---

## Hands-on Implementation Guide

### **Step 1: Environment Setup**

1. **Install Terraform**
   ```bash
   # Windows (using Chocolatey)
   choco install terraform
   
   # Or download from https://terraform.io/downloads
   # Verify installation
   terraform version
   ```

2. **Create Project Structure**
   ```bash
   cd /Learn_Docker_kubernetes/shortly
   mkdir terraform
   cd terraform
   ```

3. **Initialize Git Ignore**
   ```bash
   # Create .gitignore
   cat > .gitignore << 'EOF'
   # Terraform files
   *.tfstate
   *.tfstate.*
   *.tfvars
   .terraform/
   .terraform.lock.hcl
   crash.log
   crash.*.log
   
   # SSH keys
   *.pem
   *.ppk
   EOF
   ```

### **Step 2: Basic Configuration**

1. **Create main.tf**
   ```hcl
   # terraform/main.tf
   terraform {
     required_version = ">= 1.0"
     required_providers {
       aws = {
         source  = "hashicorp/aws"
         version = "~> 5.0"
       }
     }
   }
   
   provider "aws" {
     region = var.aws_region
   }
   
   # Get latest Ubuntu AMI
   data "aws_ami" "ubuntu" {
     most_recent = true
     owners      = ["099720109477"] # Canonical
     
     filter {
       name   = "name"
       values = ["ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-*"]
     }
   }
   
   # Security Group
   resource "aws_security_group" "shortly_sg" {
     name        = "shortly-sg"
     description = "Security group for Shortly application"
     
     ingress {
       description = "SSH"
       from_port   = 22
       to_port     = 22
       protocol    = "tcp"
       cidr_blocks = var.allowed_ssh_cidr
     }
     
     ingress {
       description = "HTTP"
       from_port   = 80
       to_port     = 80
       protocol    = "tcp"
       cidr_blocks = ["0.0.0.0/0"]
     }
     
     ingress {
       description = "HTTPS"
       from_port   = 443
       to_port     = 443
       protocol    = "tcp"
       cidr_blocks = ["0.0.0.0/0"]
     }
     
     egress {
       from_port   = 0
       to_port     = 0
       protocol    = "-1"
       cidr_blocks = ["0.0.0.0/0"]
     }
     
     tags = {
       Name = "shortly-sg"
       Project = "DevOps-Learning"
     }
   }
   
   # Key Pair
   resource "aws_key_pair" "shortly_key" {
     key_name   = var.key_name
     public_key = file(var.public_key_path)
     
     tags = {
       Name = "shortly-key"
       Project = "DevOps-Learning"
     }
   }
   
   # EC2 Instance
   resource "aws_instance" "shortly_server" {
     ami           = data.aws_ami.ubuntu.id
     instance_type = var.instance_type
     key_name      = aws_key_pair.shortly_key.key_name
     
     vpc_security_group_ids = [aws_security_group.shortly_sg.id]
     
     user_data = file("${path.module}/user-data.sh")
     
     tags = {
       Name = "shortly-server"
       Project = "DevOps-Learning"
       Environment = "production"
     }
   }
   ```

2. **Create variables.tf**
   ```hcl
   # terraform/variables.tf
   variable "aws_region" {
     description = "AWS region for resources"
     type        = string
     default     = "us-west-1"
   }
   
   variable "instance_type" {
     description = "EC2 instance type"
     type        = string
     default     = "t3.micro"
   }
   
   variable "key_name" {
     description = "AWS key pair name"
     type        = string
     default     = "shortly-key"
   }
   
   variable "public_key_path" {
     description = "Path to public key file"
     type        = string
     default     = "~/.ssh/shortly-key.pub"
   }
   
   variable "allowed_ssh_cidr" {
     description = "CIDR blocks allowed for SSH access"
     type        = list(string)
     default     = ["0.0.0.0/0"]
   }
   ```

3. **Create outputs.tf**
   ```hcl
   # terraform/outputs.tf
   output "instance_id" {
     description = "ID of the EC2 instance"
     value       = aws_instance.shortly_server.id
   }
   
   output "instance_public_ip" {
     description = "Public IP address of the EC2 instance"
     value       = aws_instance.shortly_server.public_ip
   }
   
   output "instance_public_dns" {
     description = "Public DNS name of the EC2 instance"
     value       = aws_instance.shortly_server.public_dns
   }
   
   output "security_group_id" {
     description = "ID of the security group"
     value       = aws_security_group.shortly_sg.id
   }
   
   output "ssh_command" {
     description = "SSH command to connect to the instance"
     value       = "ssh -i ~/.ssh/shortly-key.pem ubuntu@${aws_instance.shortly_server.public_ip}"
   }
   ```

### **Step 3: User Data Script**

Create automated setup script:

```bash
# terraform/user-data.sh
#!/bin/bash
set -e

# Update system
apt-get update
apt-get upgrade -y

# Install Docker
curl -fsSL https://get.docker.com -o get-docker.sh
sh get-docker.sh
usermod -aG docker ubuntu

# Install Docker Compose
curl -L "https://github.com/docker/compose/releases/latest/download/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
chmod +x /usr/local/bin/docker-compose

# Install Git
apt-get install -y git

# Create application directory
mkdir -p /opt/shortly
chown ubuntu:ubuntu /opt/shortly

# Install Nginx
apt-get install -y nginx

# Install Certbot for SSL
apt-get install -y certbot python3-certbot-nginx

# Create log directory
mkdir -p /var/log/shortly
chown ubuntu:ubuntu /var/log/shortly

# Signal completion
echo "User data script completed at $(date)" > /var/log/user-data.log
```

### **Step 4: Initialize and Test**

1. **Initialize Terraform**
   ```bash
   cd /Learn_Docker_kubernetes/shortly/terraform
   terraform init
   ```

2. **Validate Configuration**
   ```bash
   terraform validate
   ```

3. **Plan Deployment**
   ```bash
   terraform plan
   ```

4. **Apply Configuration**
   ```bash
   terraform apply
   ```

5. **Test SSH Connection**
   ```bash
   # Use output from terraform
   terraform output ssh_command
   
   # Connect to instance
   ssh -i ~/.ssh/shortly-key.pem ubuntu@<PUBLIC_IP>
   ```

---

## Advanced Terraform Concepts

### **1. State Management**

**Local State (Development)**
```hcl
# Default - stores terraform.tfstate locally
# Good for learning and development
# NOT suitable for teams or production
```

**Remote State (Production)**
```hcl
# terraform/main.tf
terraform {
  backend "s3" {
    bucket = "shortly-terraform-state"
    key    = "production/terraform.tfstate"
    region = "us-west-1"
    
    # Optional: DynamoDB for state locking
    dynamodb_table = "shortly-terraform-locks"
    encrypt        = true
  }
}
```

### **2. Modules**

**Creating Reusable Modules**
```
terraform/
├── modules/
│   └── ec2-instance/
│       ├── main.tf
│       ├── variables.tf
│       └── outputs.tf
├── environments/
│   ├── dev/
│   │   └── main.tf
│   └── prod/
│       └── main.tf
```

**Using Modules**
```hcl
# environments/prod/main.tf
module "shortly_server" {
  source = "../../modules/ec2-instance"
  
  instance_type = "t3.small"
  environment   = "production"
  key_name      = "shortly-prod-key"
}
```

### **3. Workspaces**

**Multiple Environments**
```bash
# Create workspaces
terraform workspace new dev
terraform workspace new staging
terraform workspace new prod

# Switch between workspaces
terraform workspace select prod
terraform workspace list
```

**Workspace-aware Configuration**
```hcl
# Use workspace in resource names
resource "aws_instance" "shortly_server" {
  ami           = data.aws_ami.ubuntu.id
  instance_type = terraform.workspace == "prod" ? "t3.small" : "t3.micro"
  
  tags = {
    Name = "shortly-server-${terraform.workspace}"
    Environment = terraform.workspace
  }
}
```

### **4. Data Sources and Locals**

**Data Sources**
```hcl
# Get existing VPC
data "aws_vpc" "default" {
  default = true
}

# Get availability zones
data "aws_availability_zones" "available" {
  state = "available"
}
```

**Local Values**
```hcl
locals {
  common_tags = {
    Project     = "DevOps-Learning"
    Environment = terraform.workspace
    ManagedBy   = "Terraform"
  }
  
  instance_name = "shortly-server-${terraform.workspace}"
}

resource "aws_instance" "shortly_server" {
  # ... other configuration
  tags = merge(local.common_tags, {
    Name = local.instance_name
  })
}
```

---

## Troubleshooting & Common Issues

### **1. Authentication Issues**

**Problem:** "Error: No valid credential sources found"
```bash
# Check AWS credentials
aws configure list

# Verify region
aws configure get region

# Test AWS access
aws sts get-caller-identity
```

**Solution:**
```bash
# Reconfigure AWS CLI
aws configure

# Or set environment variables
export AWS_ACCESS_KEY_ID="your-key"
export AWS_SECRET_ACCESS_KEY="your-secret"
export AWS_DEFAULT_REGION="us-west-1"
```

### **2. State Lock Issues**

**Problem:** "Error: Error locking state"
```bash
# Force unlock (use carefully)
terraform force-unlock <LOCK_ID>

# Or delete lock manually if using DynamoDB
aws dynamodb delete-item \
  --table-name terraform-locks \
  --key '{"LockID":{"S":"<LOCK_ID>"}}'
```

### **3. Resource Already Exists**

**Problem:** "Resource already exists"
```bash
# Import existing resource
terraform import aws_instance.shortly_server i-0123456789abcdef0

# Or remove from state
terraform state rm aws_instance.shortly_server
```

### **4. SSH Key Issues**

**Problem:** "Key pair 'shortly-key' already exists"
```bash
# Check existing key pairs
aws ec2 describe-key-pairs

# Delete existing key pair
aws ec2 delete-key-pair --key-name shortly-key

# Or import existing key
terraform import aws_key_pair.shortly_key shortly-key
```

### **5. AMI Not Found**

**Problem:** "InvalidAMIID.NotFound"
```hcl
# Use data source for latest AMI
data "aws_ami" "ubuntu" {
  most_recent = true
  owners      = ["099720109477"]
  
  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-*"]
  }
  
  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}
```

### **6. Debugging Tips**

**Enable Debug Logging**
```bash
export TF_LOG=DEBUG
terraform plan
```

**Validate Configuration**
```bash
terraform validate
terraform fmt
```

**Check State**
```bash
terraform show
terraform state list
terraform state show aws_instance.shortly_server
```

---

## Next Steps

After completing this Terraform fundamentals guide, you'll be ready to:

1. **Implement Basic Infrastructure** - Recreate your current EC2 setup
2. **Add Application Deployment** - Automate Shortly app deployment
3. **Enhance with Advanced Features** - Elastic IP, monitoring, backups
4. **Prepare for Kubernetes** - Use Terraform for EKS cluster provisioning

**Success Criteria:**
- ✅ Terraform successfully provisions equivalent infrastructure
- ✅ Shortly application deploys and functions identically
- ✅ Infrastructure can be torn down and recreated reliably
- ✅ Code is version-controlled and well-documented

**Learning Outcomes:**
- Understanding of Infrastructure as Code principles
- Hands-on experience with Terraform and AWS provider
- Ability to automate infrastructure provisioning
- Foundation for advanced DevOps practices

---

*This document serves as a comprehensive guide to Terraform fundamentals in the context of our Shortly URL shortener DevOps journey. It will be referenced and updated as we progress through the implementation.* 