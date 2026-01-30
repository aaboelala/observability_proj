variable "region" {
  description = "The AWS region to deploy the VPC"
  type        = string
  default     = "us-east-1"

}
variable "cidr_block" {
  description = "The CIDR block for the VPC"
  type        = string
}

variable "vpc_name" {
  description = "The name of the VPC"
  type        = string
  default     = "todo-list-vpc"
}

variable "vpc_azs" {
  description = "The availability zones for the VPC"
  type        = list(string)
}

variable "vpc_private_subnets" {
  description = "The private subnets for the VPC"
  type        = list(string)
}

variable "vpc_public_subnets" {
  description = "The public subnets for the VPC"
  type        = list(string)
}
variable "cluster_name" {
  description = "The name of the EKS cluster"
  type        = string
  default     = "my-todo-list-eks-cluster"
}
//////////////////////////////////////////////////////////////////////////////////////
variable "cluster_version" {
  description = "The version of the EKS cluster"
  type        = string
}

variable "node_groups" {
  description = "EKS node groups configuration"
  type = map(object({
    instance_types = list(string)
    capacity_type  = string
    scaling_config = object({
      desired_size = number
      max_size     = number
      min_size     = number
    })
    ssh_key_name = optional(string)
  }))
  default = {
    "Name" = {
      instance_types = ["t2.medium"]
      capacity_type  = "ON_DEMAND"
      scaling_config = {
        desired_size = 3
        max_size     = 4
        min_size     = 1
      }
      ssh_key_name = "my-key"
    }
  }
}

variable "argo_cd_namespace" {
  description = "The namespace for ArgoCD"
  type        = string
  default     = "argocd-ns"
}

variable "app_namespace" {
  description = "The namespace for the Application"
  type        = string
  default     = "todo-list-app-ns"

}

variable "observability_namespace" {
  description = "The namespace for Observability"
  type        = string
  default     = "observability-ns"

}
