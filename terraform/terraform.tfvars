# terraform.tfvars - OPTIMIZED FOR SPEED
# Infrastructure Configuration for Solar System App
region = "us-east-1"

cidr_block = "10.0.0.0/16"
vpc_azs    = ["us-east-1a", "us-east-1b"] # Reduced from 3 to 2 AZs


vpc_private_subnets = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"] # Reduced from 3 to 2
vpc_public_subnets  = ["10.0.4.0/24", "10.0.5.0/24", "10.0.6.0/24"] # Reduced from 3 to 2

# EKS Cluster Configuration
cluster_name    = "todo-list-app-cluster"
cluster_version = "1.30"

# Node Groups Configuration - OPTIMIZED FOR SPEED
node_groups = {
  # Single medium node for faster provisioning
  general = {
    instance_types = ["t3.medium"] # Medium instance = balanced performance
    capacity_type  = "ON_DEMAND"
    scaling_config = {
      desired_size = 3 # Single node for development
      max_size     = 4 # Reduced max
      min_size     = 1
    }

    ssh_key_name = "key"
  }
}
