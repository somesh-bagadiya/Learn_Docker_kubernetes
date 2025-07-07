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

output "elastic_ip" {
  description = "Elastic IP address"
  value       = aws_eip.shortly_eip.public_ip
}

output "security_group_id" {
  description = "ID of the security group"
  value       = aws_security_group.shortly_sg.id
}

output "key_pair_name" {
  description = "Name of the key pair"
  value       = aws_key_pair.shortly_key.key_name
}

output "ssh_command" {
  description = "SSH command to connect to the instance"
  value       = "ssh -i ./shortly-key ubuntu@${aws_eip.shortly_eip.public_ip}"
}

output "application_url" {
  description = "URL where the Shortly application will be accessible"
  value       = "https://${aws_eip.shortly_eip.public_ip}"
}

output "infrastructure_summary" {
  description = "Summary of created infrastructure"
  value = {
    region           = var.aws_region
    instance_type    = var.instance_type
    instance_id      = aws_instance.shortly_server.id
    public_ip        = aws_eip.shortly_eip.public_ip
    security_group   = aws_security_group.shortly_sg.id
    key_pair         = aws_key_pair.shortly_key.key_name
  }
}

# EKS Cluster Outputs
output "cluster_name" {
  description = "Name of the EKS cluster"
  value       = aws_eks_cluster.shortly_cluster.name
}

output "cluster_endpoint" {
  description = "Endpoint for EKS control plane"
  value       = aws_eks_cluster.shortly_cluster.endpoint
}

output "cluster_security_group_id" {
  description = "Security group ID attached to the EKS cluster"
  value       = aws_eks_cluster.shortly_cluster.vpc_config[0].cluster_security_group_id
}

output "cluster_version" {
  description = "The Kubernetes version for the EKS cluster"
  value       = aws_eks_cluster.shortly_cluster.version
}

output "node_group_arn" {
  description = "Amazon Resource Name (ARN) of the EKS Node Group"
  value       = aws_eks_node_group.shortly_nodes.arn
}

output "node_group_status" {
  description = "Status of the EKS Node Group"
  value       = aws_eks_node_group.shortly_nodes.status
}

output "vpc_id" {
  description = "ID of the VPC where the cluster is deployed"
  value       = aws_vpc.eks_vpc.id
}

output "private_subnet_ids" {
  description = "List of private subnet IDs"
  value       = aws_subnet.private[*].id
}

output "public_subnet_ids" {
  description = "List of public subnet IDs"
  value       = aws_subnet.public[*].id
} 