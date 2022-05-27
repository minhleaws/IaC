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

variable "assume_role_policy" {
  description = "(Required) Assume role policy"
  type        = string
}

variable "aws_managed_policy_arns" {
  description = "(Optional) AWS Managed Policy ARNs"
  type        = list(string)
  default     = []
}

variable "iam_policy_name" {
  description = "(Optional) IAM Policy name"
  type        = string
  default     = null
}

variable "policies" {
  description = "(Optional) IAM Policy statements"
  type        = string
  default     = null
}
