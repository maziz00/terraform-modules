# Example: Complete AWS VPC
# VPC with 3 AZs, public/private subnets, NAT HA, flow logs

provider "aws" {
  region = "me-south-1" # Bahrain — closest to UAE
}

module "vpc" {
  source = "../../"

  name       = "production"
  cidr_block = "10.0.0.0/16"

  azs                  = ["me-south-1a", "me-south-1b", "me-south-1c"]
  public_subnet_cidrs  = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
  private_subnet_cidrs = ["10.0.11.0/24", "10.0.12.0/24", "10.0.13.0/24"]

  enable_nat_gateway  = true
  single_nat_gateway  = false # One NAT per AZ for HA — set true for dev/staging
  enable_flow_logs    = true
  flow_log_retention_days = 30

  tags = {
    Environment = "production"
    ManagedBy   = "terraform"
    Project     = "platform"
  }
}

output "vpc_id" {
  value = module.vpc.vpc_id
}

output "private_subnet_ids" {
  value = module.vpc.private_subnet_ids
}

output "public_subnet_ids" {
  value = module.vpc.public_subnet_ids
}
