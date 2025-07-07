#!/bin/bash
set -e

# Log all output
exec > >(tee /var/log/user-data.log) 2>&1

echo "Starting user data script at $(date)"

# Update system
echo "Updating system packages..."
apt-get update
apt-get upgrade -y

# Install Docker
echo "Installing Docker..."
curl -fsSL https://get.docker.com -o get-docker.sh
sh get-docker.sh
usermod -aG docker ubuntu

# Install Docker Compose
echo "Installing Docker Compose..."
curl -L "https://github.com/docker/compose/releases/latest/download/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
chmod +x /usr/local/bin/docker-compose
ln -sf /usr/local/bin/docker-compose /usr/bin/docker-compose

# Install Git
echo "Installing Git..."
apt-get install -y git

# Install other utilities
echo "Installing additional utilities..."
apt-get install -y curl wget unzip htop

# Create application directory
echo "Creating application directory..."
mkdir -p /opt/shortly
chown ubuntu:ubuntu /opt/shortly

# Install Nginx
echo "Installing Nginx..."
apt-get install -y nginx

# Install Certbot for SSL
echo "Installing Certbot..."
apt-get install -y certbot python3-certbot-nginx

# Create log directory
echo "Creating log directories..."
mkdir -p /var/log/shortly
chown ubuntu:ubuntu /var/log/shortly

# Configure UFW firewall
echo "Configuring firewall..."
ufw --force enable
ufw allow 22/tcp
ufw allow 80/tcp
ufw allow 443/tcp

# Create a script to deploy the Shortly application
cat > /opt/shortly/deploy.sh << 'EOF'
#!/bin/bash
set -e

echo "Deploying Shortly application..."

# Clone the repository
cd /opt/shortly
if [ ! -d "Learn_Docker_kubernetes" ]; then
    git clone https://github.com/somesh-bagadiya/Learn_Docker_kubernetes.git
fi

cd Learn_Docker_kubernetes/shortly

# Pull latest changes
git pull origin main

# Build and start the application
docker-compose down --remove-orphans || true
docker-compose up -d

echo "Shortly application deployed successfully!"
EOF

chmod +x /opt/shortly/deploy.sh
chown ubuntu:ubuntu /opt/shortly/deploy.sh

# Create a systemd service to ensure Docker starts on boot
systemctl enable docker

# Create a health check script
cat > /usr/local/bin/health-check.sh << 'EOF'
#!/bin/bash

# Check if Docker is running
if ! systemctl is-active --quiet docker; then
    echo "$(date): Docker is not running" >> /var/log/shortly/health-check.log
    exit 1
fi

# Check if containers are running
if [ -f /opt/shortly/Learn_Docker_kubernetes/shortly/docker-compose.yml ]; then
    cd /opt/shortly/Learn_Docker_kubernetes/shortly
    if ! docker-compose ps | grep -q "Up"; then
        echo "$(date): Shortly containers are not running" >> /var/log/shortly/health-check.log
        exit 1
    fi
fi

echo "$(date): Health check passed" >> /var/log/shortly/health-check.log
EOF

chmod +x /usr/local/bin/health-check.sh

# Add health check to crontab
echo "0 */6 * * * /usr/local/bin/health-check.sh" | crontab -u ubuntu -

# Run the deployment script
echo "Running deployment script..."
sudo -u ubuntu /opt/shortly/deploy.sh

# Signal completion
echo "User data script completed successfully at $(date)"
echo "READY" > /var/log/user-data-complete 