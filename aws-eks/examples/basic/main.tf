# Example: Basic EKS Cluster
# Minimal setup — single On-Demand node group, private endpoint

provider "aws" {
  region = "me-south-1"
}

module "vpc" {
  source = "../../../aws-vpc"

  name       = "eks-basic"
  cidr_block = "10.0.0.0/16"
  azs        = ["me-south-1a", "me-south-1b", "me-south-1c"]

  public_subnet_cidrs  = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
  private_subnet_cidrs = ["10.0.11.0/24", "10.0.12.0/24", "10.0.13.0/24"]

  enable_nat_gateway = true
  single_nat_gateway = true # Cost-saving for dev

  tags = { Environment = "dev" }
}

module "eks" {
  source = "../../"

  cluster_name       = "dev-cluster"
  cluster_version    = "1.29"
  vpc_id             = module.vpc.vpc_id
  private_subnet_ids = module.vpc.private_subnet_ids

  cluster_endpoint_public_access  = true # Allow kubectl from outside for dev
  cluster_endpoint_private_access = true

  node_groups = {
    general = {
      instance_types = ["t3.large"]
      min_size       = 1
      max_size       = 3
      desired_size   = 2
    }
  }

  tags = { Environment = "dev" }
}

output "cluster_endpoint" {
  value = module.eks.cluster_endpoint
}
