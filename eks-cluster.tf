module "eks" {
  source                          = "terraform-aws-modules/eks/aws"
  version                         = "~>20.0"
  cluster_name                    = local.cluster_name
  cluster_version                 = "1.29"
  cluster_endpoint_private_access = true
  cluster_endpoint_public_access  = true
  vpc_id                          = module.vpc.vpc_id
  subnet_ids                      = module.vpc.private_subnets

  cluster_addons = {
    coredns = {
      resolve_conflicts = "OVERWRITE"
    }
    kube-proxy = {}
    vpc-cni = {
      resolve_conflicts = "OVERWRITE"
    }
    aws-ebs-csi-driver = {
      service_account_role_arn = module.ebs_csi_irsa_role.iam_role_arn
      most_recent = true
    }
  }

  # Cluster access entry
  # To add the current caller identity as an administrator
  enable_cluster_creator_admin_permissions = true

  eks_managed_node_group_defaults = {
    disk_size              = 30
    instance_types         = ["t2-medium"]
    vpc_security_group_ids = [aws_security_group.eks-sg.id]
  }

  eks_managed_node_groups = {
    support = {
      min_size     = 2
      max_size     = 3
      desired_size = 2

      instance_types = ["t2.medium"]


      tags = {
        Name = "RC-Support"
        Terraform = "true"
      }
    }
  }
}

module "ebs_csi_irsa_role" {
  source = "terraform-aws-modules/iam/aws//modules/iam-role-for-service-accounts-eks"

  role_name             = "${local.cluster_name}-ebs-csi-role"
  attach_ebs_csi_policy = true

  oidc_providers = {
    ex = {
      provider_arn               = module.eks.oidc_provider_arn
      namespace_service_accounts = ["kube-system:ebs-csi-controller-sa"]
    }
  }
}


# data "aws_eks_cluster" "cluster" {
#   name = module.eks.cluster_id
# }

# data "aws_eks_cluster_auth" "cluster" {
#   name = module.eks.cluster_id
# }

