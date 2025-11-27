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
}