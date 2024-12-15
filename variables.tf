
variable "policyArn" {
  default = "arn:aws:eks::aws:cluster-access-policy/AmazonEKSClusterAdminPolicy"
}

variable "kubernetes_namespace" {
  description = "The Kubernetes namespace where the resources will be provisioned"
  type        = string
  default     = "default"
}

variable "cluster_name" {
  description = "Name of the EKS Cluster"
  type        = string
  default     = "tech-challenge-eks"
}

variable "instance_type" {
  description = "EC2 instance type"
  type        = string
  default     = "t3.medium"
}

variable "lambda_sg_name" {
  description = "Security Group Name for the Lambda"
  type        = string
  default     = "lambda_sg"
}

variable "vpc_name" {
  description = "VPC Name - VPC Created in the infrastructure repo"
  type        = string
  default     = "tech_challenge_vpc"
}

variable "aws_region" {
  description = "AWS region"
  type        = string
  default     = "us-east-1"
}


variable "vpc_cidr_block" {
  description = "CIDR block for the VPC"
  type        = string
  default     = "10.0.0.0/16"
}

variable "subnet_public_1_cidr_block" {
  description = "CIDR block for the first public subnet"
  type        = string
  default     = "10.0.1.0/24"
}

variable "subnet_public_2_cidr_block" {
  description = "CIDR block for the secondary public subnet"
  type        = string
  default     = "10.0.2.0/24"
}

variable "subnet_private_1_cidr_block" {
  description = "CIDR block for the first subnet"
  type        = string
  default     = "10.0.3.0/24"
}

variable "subnet_private_2_cidr_block" {
  description = "CIDR block for the first subnet"
  type        = string
  default     = "10.0.4.0/24"
}

variable "subnet_availability_zone_az_1" {
  description = "Availability zone for the subnets"
  type        = string
  default     = "us-east-1a"
}

variable "subnet_availability_zone_az_2" {
  description = "Availability zone 2 for the subnets"
  type        = string
  default     = "us-east-1b"
}



