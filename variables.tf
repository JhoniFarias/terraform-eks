variable "appName" {
  default = "tech-challenge-eks"
}

variable "authMode" {
  default = "API_AND_CONFIG_MAP"
}

variable "policyArn" {
  default = "arn:aws:eks::aws:cluster-access-policy/AmazonEKSClusterAdminPolicy"
}

variable "instanceType" {
  default = "t3.medium"

}

variable "principalArn" {
  default = ""
}

variable "cidrBlocks" {
  default = "172.31.0.0/16"
}