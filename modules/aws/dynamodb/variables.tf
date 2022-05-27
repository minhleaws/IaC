variable "common_tags" {
  description = "(Optional) Common tags"
  type        = map(string)
  default     = null
}

variable "dynamodb_tags" {
  description = "(Optional) DynamoDB tags"
  type        = map(string)
  default     = null
}

variable "table_name" {
  description = "(Required) The name of the table, this needs to be unique within a region."
  type        = string
}

variable "billing_mode" {
  description = "(Required) Controls how you are charged for read and write throughput and how you manage capacity. The valid values are PROVISIONED and PAY_PER_REQUEST"
  type        = string
}

variable "partition_key" {
  description = "(Required) The attribute to use as the hash (partition) key."
  type        = string
}

variable "partition_key_attr" {
  description = "(Required) Attribute of (partition) key"
  type        = string
}


variable "sort_key" {
  description = "(Required) The attribute to use as the range (sort) key."
  type        = string
}

variable "sort_key_attr" {
  description = "(Required) Attribute of (sort) key."
  type        = string
}

variable "server_side_encryption_enable" {
  description = "(Optional) Whether or not to enable encryption at rest using an AWS managed KMS customer master key (CMK)."
  type        = bool
  default     = false
}

variable "kms_key_arn" {
  description = "(Optional) The ARN of the CMK that should be used for the AWS KMS encryption."
  type        = string
  default     = "alias/aws/dynamodb"
}

variable "point_in_time_recovery" {
  description = "(Optional) Whether to enable point-in-time recovery - note that it can take up to 10 minutes to enable for new tables."
  type        = bool
  default     = false
}
