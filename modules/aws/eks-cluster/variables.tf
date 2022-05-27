variable "eks_cluster_name" {
  description = "(Required) EKS Cluster name"
  type        = string
}

variable "eks_cluster_version" {
  description = "(Required) EKS Cluster version"
  type        = string
}

variable "eks_cluster_role_arn" {
  description = "(Required) EKS Cluster role arn"
  type        = string
}

variable "eks_cluster_subnets_ids" {
  description = "(Required) EKS Cluster subnet ids"
  type        = list(string)
}

variable "eks_cluster_additional_sg_ids" {
  description = "(Required) EKS Cluster Additional SG ids"
  type        = list(string)
}

variable "eks_cluster_control_plane_log_retention" {
  description = "(Optional) EKS Cluster Controll Plane Logging retention in day"
  type        = number
  default     = 30
}

variable "endpoint_private_access" {
  description = "(Optional) Whether the Amazon EKS private API server endpoint is enabled. Default is false"
  type        = bool
  default     = false
}

variable "endpoint_public_access" {
  description = "(Optional) Whether the Amazon EKS public API server endpoint is enabled. Default is true"
  type        = bool
  default     = true
}

variable "public_access_cidrs" {
  description = "(Optional) List of CIDR blocks. Indicates which CIDR blocks can access the Amazon EKS public API server endpoint when enabled"
  type        = list(string)
  default     = ["0.0.0.0/0"]
}

variable "secret_encryption_config" {
  description = "(Optional) Configuration block with encryption configuration for the cluster."
  type = list(object({
    provider_key_arn = string
    resources        = list(string)
  }))
  default = []
}
