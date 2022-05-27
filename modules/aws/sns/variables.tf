variable "common_tags" {
  description = "(Optional) Common tags"
  type        = map(string)
  default     = null
}

variable "sns_tags" {
  description = "(Optional) Topic tags"
  type        = map(string)
  default     = null
}

variable "name" {
  description = "(Required) SNS Topic name"
  type        = string
}

variable "kms_key_arn" {
  description = "(Optional) The ID of an AWS-managed customer master key (CMK) for Amazon SNS or a custom CMK."
  type        = string
  default     = "alias/aws/sns"
}

variable "policy" {
  description = "(Optional) The fully-formed AWS policy as JSON"
  type        = string
  default     = null
}

variable "subcription_emails" {
  description = "(Optional) Subcription emails"
  type        = list(string)
  default     = []
}
