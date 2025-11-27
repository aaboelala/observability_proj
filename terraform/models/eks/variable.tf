variable "cluster_name" {
    description = "The name of the EKS cluster"
    type        = string
}
variable "cluster_version" {
    description = "The version of the EKS cluster"
    type        = string
    default     = "1.21"
}
variable "subnet_ids" {
    description = "The subnet IDs for the EKS cluster"
    type        = list(string)
}
variable "node_groups" {
  description   = "EKS node groups configuration"
  type          = map(object({
    instance_types = list(string)
    capacity_type  = string
    scaling_config = object({
      desired_size = number
      max_size     = number
      min_size     = number 
    })
  }))
}
variable "vpc_id" {
    description = "The VPC ID for the EKS cluster"
    type        = string
  
}