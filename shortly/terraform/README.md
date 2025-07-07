# Shortly App Infrastructure - Terraform

This directory contains Infrastructure as Code (IaC) definitions to provision AWS infrastructure for the Shortly URL shortener application.

## 🎯 **What This Creates**

- **EC2 Instance**: Ubuntu 22.04 LTS with Docker and Docker Compose
- **Security Group**: SSH (22), HTTP (80), HTTPS (443) access
- **Key Pair**: SSH key for secure access
- **Elastic IP**: Static IP address for consistent access
- **Automated Setup**: User data script installs all dependencies

## 📋 **Prerequisites**

1. **Terraform installed** (v1.0+)
2. **AWS CLI configured** with credentials
3. **SSH key pair** exists at `~/.ssh/shortly-key.pub`

## 🚀 **Quick Start**

```bash
# 1. Navigate to terraform directory
cd /Learn_Docker_kubernetes/shortly/terraform

# 2. Copy example variables (optional customization)
cp terraform.tfvars.example terraform.tfvars
# Edit terraform.tfvars if needed

# 3. Initialize Terraform
terraform init

# 4. Review the plan
terraform plan

# 5. Apply the configuration
terraform apply
# Type 'yes' when prompted

# 6. Get connection info
terraform output ssh_command
```

## 📁 **File Structure**

```
terraform/
├── main.tf                    # Main infrastructure configuration
├── variables.tf               # Input variable definitions
├── outputs.tf                 # Output value definitions
├── user-data.sh              # EC2 initialization script
├── terraform.tfvars.example  # Example variables file
├── .gitignore                # Git ignore rules
└── README.md                 # This file
```

## 🔧 **Configuration Variables**

| Variable | Description | Default |
|----------|-------------|---------|
| `aws_region` | AWS region | `us-west-1` |
| `instance_type` | EC2 instance type | `t3.micro` |
| `key_name` | SSH key pair name | `shortly-key-terraform` |
| `public_key_path` | Path to SSH public key | `~/.ssh/shortly-key.pub` |
| `allowed_ssh_cidr` | IP ranges for SSH access | `["0.0.0.0/0"]` |

## 📤 **Outputs**

After successful deployment, Terraform provides:

- **Instance ID**: EC2 instance identifier
- **Public IP**: Elastic IP address
- **SSH Command**: Ready-to-use SSH connection command
- **Application URL**: Where the app will be accessible

## 🔄 **Common Commands**

```bash
# View current state
terraform show

# List all resources
terraform state list

# Get specific output
terraform output instance_public_ip

# Update infrastructure
terraform plan
terraform apply

# Destroy infrastructure
terraform destroy
```

## 🔒 **Security Notes**

- SSH key pairs are managed by Terraform
- Security groups allow minimal required access
- User data script configures UFW firewall
- All resources tagged for easy identification

## 🐛 **Troubleshooting**

### Key Pair Issues
```bash
# Check if public key exists
ls -la ~/.ssh/shortly-key.pub

# Generate new key pair if needed
ssh-keygen -t rsa -b 4096 -f ~/.ssh/shortly-key
```

### AWS Authentication
```bash
# Verify AWS credentials
aws configure list
aws sts get-caller-identity
```

### Terraform Issues
```bash
# Enable debug logging
export TF_LOG=DEBUG
terraform plan

# Force unlock if needed
terraform force-unlock <LOCK_ID>
```

## 📚 **Next Steps**

After infrastructure is created:

1. **SSH into instance**: Use the provided SSH command
2. **Deploy application**: Run `/opt/shortly/deploy.sh`
3. **Configure domain**: Point your domain to the Elastic IP
4. **Set up SSL**: Use Certbot for HTTPS certificates

## 🔄 **Integration with Existing Setup**

This Terraform configuration creates **new** infrastructure alongside your existing manually-created resources. Resource names include `-terraform` suffix to avoid conflicts.

To migrate from manual to Terraform-managed infrastructure:
1. Deploy with Terraform
2. Test functionality
3. Update DNS to point to new Elastic IP
4. Clean up old manual resources

---

*This infrastructure code is part of the DevOps learning journey for the Shortly URL shortener application.* 