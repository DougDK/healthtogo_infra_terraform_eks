variable "vpc_cidr_block" {
  description = ""
  type = string
}

variable "subnet_cidr_block" {
  description = ""
  type = list(string)
}

variable "env" {
  description = "environment"
  type        = string
}

# variable "cluster_prefix" {
#   description = "prefix of cluster name"
#   type        = string
#   default     = "k8s"
# }

variable "eks_version" {
  description = "Kubernetes version to use for the EKS cluster."
  type        = string
}

# variable "cluster_subnets" {
#   description = "private subnets for the cluster to use"
#   type        = list(string)
# }

# variable "eks_kms_arn" {}
