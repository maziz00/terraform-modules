# Example: Production EKS Cluster
# Private endpoint, mixed node groups, IRSA, KMS, autoscaler

provider "aws" {
  region = "me-south-1"
}

module "vpc" {
  source = "../../../aws-vpc"

  name       = "eks-prod"
  cidr_block = "10.0.0.0/16"
  azs        = ["me-south-1a", "me-south-1b", "me-south-1c"]

  public_subnet_cidrs  = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
  private_subnet_cidrs = ["10.0.11.0/24", "10.0.12.0/24", "10.0.13.0/24"]

  enable_nat_gateway = true
  single_nat_gateway = false # HA — one NAT per AZ

  tags = {
    Environment = "production"
    ManagedBy   = "terraform"
  }
}

module "eks" {
  source = "../../"

  cluster_name       = "production"
  cluster_version    = "1.29"
  vpc_id             = module.vpc.vpc_id
  private_subnet_ids = module.vpc.private_subnet_ids
  public_subnet_ids  = module.vpc.public_subnet_ids

  # Private API endpoint only — access via VPN or bastion
  cluster_endpoint_public_access  = false
  cluster_endpoint_private_access = true

  # KMS encryption for etcd secrets
  enable_secrets_encryption = true

  # Cluster Autoscaler IRSA role
  enable_cluster_autoscaler = true

  node_groups = {
    # On-Demand nodes for system workloads
    system = {
      instance_types = ["m5.xlarge"]
      min_size       = 2
      max_size       = 5
      desired_size   = 3
      labels = {
        workload-type = "system"
      }
    }

    # Spot nodes for stateless application workloads
    spot-apps = {
      instance_types = ["m5.xlarge", "m5a.xlarge", "m5d.xlarge"]
      capacity_type  = "SPOT"
      min_size       = 0
      max_size       = 20
      desired_size   = 3
      labels = {
        workload-type = "application"
      }
      taints = [{
        key    = "spot"
        value  = "true"
        effect = "NO_SCHEDULE"
      }]
    }
  }

  # Grant access to the ops team IAM role
  aws_auth_roles = [
    {
      rolearn  = "arn:aws:iam::123456789012:role/DevOpsTeam"
      username = "devops"
      groups   = ["system:masters"]
    },
    {
      rolearn  = "arn:aws:iam::123456789012:role/DeveloperTeam"
      username = "developer"
      groups   = ["developer-group"]
    }
  ]

  tags = {
    Environment = "production"
    ManagedBy   = "terraform"
    CostCenter  = "platform"
  }
}

output "cluster_endpoint" {
  value = module.eks.cluster_endpoint
}

output "cluster_autoscaler_role_arn" {
  value = module.eks.cluster_autoscaler_role_arn
}

output "oidc_provider_arn" {
  value = module.eks.oidc_provider_arn
}
