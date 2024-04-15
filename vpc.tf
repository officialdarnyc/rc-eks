data "aws_availability_zones" "available" {}

resource "random_string" "suffix" {
  length  = 8
  special = false
}

module "vpc" {
  name = "support-eks"

  cidr = "120.0.0.0/16"
  source  = "terraform-aws-modules/vpc/aws"
  version = "~> 5.0"
  azs                  = data.aws_availability_zones.available.names
  private_subnets      = ["120.0.1.0/24", "120.0.2.0/24", "120.0.3.0/24"]
  public_subnets       = ["120.0.4.0/24", "120.0.5.0/24", "120.0.6.0/24"]
  enable_nat_gateway   = true
  single_nat_gateway   = true
  enable_dns_hostnames = true
  manage_default_security_group = false

  tags = {
    "kubernetes.io/cluster/${local.cluster_name}" = "shared"
    "Name" = "rc/support"
  }

  public_subnet_tags = {
    "kubernetes.io/cluster/${local.cluster_name}" = "shared"
    "kubernetes.io/role/elb"                      = "1"
  }

  private_subnet_tags = {
    "kubernetes.io/cluster/${local.cluster_name}" = "shared"
    "kubernetes.io/role/internal-elb"             = "1"
  }
}
