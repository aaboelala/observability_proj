
module "vpc" {
    
  source = "./models/vpc"
  vpc_name            = var.vpc_name
  cidr_block         = var.cidr_block
  vpc_public_subnets  = var.vpc_public_subnets
  vpc_private_subnets = var.vpc_private_subnets
  cluster_name       = var.cluster_name
  vpc_azs            = var.vpc_azs
}

module "eks" {
  source = "./models/eks"
  cluster_name    = var.cluster_name
  vpc_id          = module.vpc.vpc_id
  cluster_version = var.cluster_version
  subnet_ids      = module.vpc.private_subnet_ids
  node_groups     = var.node_groups
  depends_on      = [ module.vpc ]
}

resource "aws_eks_addon" "metrics_server" {
  cluster_name                = module.eks.cluster_name
  addon_name                  = "metrics-server"
  addon_version               = null
  resolve_conflicts_on_create = "OVERWRITE"
  resolve_conflicts_on_update = "OVERWRITE"
  depends_on                  = [ module.eks ]
  service_account_role_arn    = module.eks.service_account_role_arn

}