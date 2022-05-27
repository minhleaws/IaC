variable "common_tags" {
  description = "(Optional) Common tags"
  type        = map(string)
  default     = null
}

variable "security_group_name" {
  description = "(Required) Security Group name"
  type        = string
}

variable "description" {
  description = "(Required) Security Group description"
  type        = string
}

variable "vpc_id" {
  description = "(Required) VPC ID"
  type        = string
}

variable "sg_tags" {
  description = "(Optional) Security Group tags"
  type        = map(string)
  default     = null
}

variable "ingress_rules" {
  description = "(Optional) Security Group rules for ingress"
  type        = any # list(map(any))
  default     = []
}

variable "egress_rules" {
  description = "(Optional) Security Group rules for egress"
  type        = any # list(map(any))
  default     = []
}
