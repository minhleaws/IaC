variable "name" {
  description = "(Required) Bucket name"
  type        = string
}

variable "common_tags" {
  description = "(Optional) Common tags"
  type        = map(string)
  default     = null
}

variable "tags" {
  description = "(Optional) Bucket tags"
  type        = map(string)
  default     = null
}


variable "versioning" {
  description = "(Optional) Enable/disable bucket versioning"
  type        = bool
  default     = true
}

variable "policy" {
  description = "(Optional) Bucket policy"
  type        = string
  default     = null
}

variable "acl" {
  description = "(Optional) The canned ACL to apply"
  type        = string
  default     = "private"
}

variable "kms_cmk_arn" {
  description = "(Optional) Encryption bucket with specify CMK"
  type        = string
  default     = null
}

variable "lifecycle_rules" {
  description = "(Optional) Bucket lifecycle rules"
  type        = any
  default     = []
}

variable "block_public_acls" {
  type    = bool
  default = true
}

variable "block_public_policy" {
  type    = bool
  default = true
}

variable "ignore_public_acls" {
  type    = bool
  default = true
}

variable "restrict_public_buckets" {
  type    = bool
  default = true
}
