variable "common_tags" {
  description = "(Optional) Common tags"
  type        = map(string)
  default     = null
}

variable "iam_role_tags" {
  description = "(Optional) IAM Role tags"
  type        = any
  default     = null
}

variable "iam_role_name" {
  description = "(Required) IAM Role name"
  type        = string
}

variable "iam_policy_name" {
  description = "(Required) IAM Policy name"
  type        = string
}

variable "policy" {
  description = "(Required) IAM Policy statements"
  type        = string
}

variable "openid_connect_provider_url" {
  description = "(Required) OIDC provider URL"
  type        = string
}

variable "openid_connect_provider_arn" {
  description = "(Required) OIDC provider ARN"
  type        = string
}

variable "namespace" {
  description = "(Required) Kubernetes namespace"
  type        = string
}

variable "service_account" {
  description = "(Required) Kubernetes service account"
  type        = string
}

variable "cluster" {
  description = "(Required) EKS cluster ID"
  type        = string
}
