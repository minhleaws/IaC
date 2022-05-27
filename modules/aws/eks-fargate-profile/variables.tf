variable "common_tags" {
  description = "(Optional) Common tags"
  type        = map(string)
  default     = null
}

variable "fargate_profile_tags" {
  description = "(Optional) EKS Fargate profile tags"
  type        = map(string)
  default     = null
}

variable "eks_cluster_name" {
  description = "(Required) EKS Cluster name"
  type        = string
}

variable "fargate_profile_name" {
  description = "(Required) EKS Fargate profile name"
  type        = string
}

variable "pod_execution_role_arn" {
  description = "(Required) EKS Fargate profile IAM role"
  type        = string
}

variable "subnet_ids" {
  description = "(Required) Subnet IDs"
  type        = list(string)
}

variable "namespace" {
  description = "(Required) Kubernetes namespace"
  type        = string
}

variable "labels" {
  description = "(Option) Kubernetes labels"
  type        = map(string)
  default     = null
}
