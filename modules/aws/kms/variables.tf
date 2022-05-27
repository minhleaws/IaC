variable "description" {
  description = "(Optional) Key description"
  type        = string
  default     = null
}

variable "key_usage" {
  description = "(Optional) Key usage. Default is ENCRYPT_DECRYPT"
  type        = string
  default     = "ENCRYPT_DECRYPT"
}

variable "deletion_window_in_days" {
  description = "(Optional) The waiting period, specified in number of days"
  type        = number
  default     = 7
}

variable "is_enabled" {
  description = "(Optional) Specifies whether the key is enabled"
  type        = bool
  default     = true
}

variable "enable_key_rotation" {
  description = " (Optional) Specifies whether key rotation is enabled"
  type        = bool
  default     = true
}

variable "customer_master_key_spec" {
  description = "(Optional) Specifies whether the key contains a symmetric key or an asymmetric key pair and the encryption algorithms or signing algorithms that the key supports."
  type        = string
  default     = "SYMMETRIC_DEFAULT"
}

variable "policy" {
  description = "(Optional) A valid policy JSON document."
  type        = string
  default     = null
}

variable "alias" {
  description = "(Required) The name must start with the word alias followed by a forward slash (alias/)"
  type        = string
}

variable "common_tags" {
  description = "(Optional) Common tags"
  type        = map(string)
  default     = null
}

variable "tags" {
  description = "(Optional) KMS key tags"
  type        = map(string)
  default     = null
}
