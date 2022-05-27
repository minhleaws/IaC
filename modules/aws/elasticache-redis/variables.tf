variable "common_tags" {
  description = "(Optional) Common tags"
  type        = map(string)
  default     = null
}

variable "subnet_ids" {
  description = "(Required) Subnet IDs"
  type        = list(string)
}

variable "cluster_name" {
  description = "(Required) The cluster identifier"
  type        = string
}

variable "family" {
  description = "(Required) The family of the parameter group"
  type        = string
}

variable "replication_group_description" {
  description = "(Optional) A user-created description for the replication group."
  type        = string
  default     = ""
}

variable "security_group_ids" {
  description = "(Required) One or more Amazon VPC security groups associated with this replication group"
  type        = list(string)
}

variable "engine_version" {
  description = "(Required) The version number of the cache engine to be used for the cache clusters in this replication group."
  type        = string
}

variable "port" {
  description = "(Optional) The port number on which each of the cache nodes will accept connections."
  type        = number
  default     = 6379
}

variable "node_type" {
  description = "(Required) The instance class to be used"
  type        = string
}

variable "node_size" {
  description = "(Optional) The number of cache clusters (primary and replicas) this replication group will have."
  type        = string
}

variable "automatic_failover_enabled" {
  description = "(Optional) Specifies whether a read-only replica will be automatically promoted to read/write primary if the existing primary fails. If enabled, number_cache_clusters must be greater than 1. Must be enabled for Redis (cluster mode enabled) replication groups."
  type        = bool
  default     = false
}

variable "availability_zones" {
  description = "(Required) A list of EC2 availability zones in which the replication group's cache clusters will be created. The order of the availability zones in the list is not important."
  type        = list(string)
}

variable "multi_az_enabled" {
  description = "(Optional) Specifies whether to enable Multi-AZ Support for the replication group. If true, automatic_failover_enabled must also be enabled"
  type        = bool
  default     = false
}

variable "maintenance_window" {
  description = "(Optional) Specifies the weekly time range for when maintenance on the cache cluster is performed. The format is ddd:hh24:mi-ddd:hh24:mi (24H Clock UTC). The minimum maintenance window is a 60 minute period."
  type        = string
  default     = "sun:05:00-sun:09:00"
}

variable "snapshot_window" {
  description = "(Optional, Redis only) The daily time range (in UTC) during which ElastiCache will begin taking a daily snapshot of your cache cluster. The minimum snapshot window is a 60 minute period."
  type        = string
  default     = "05:00-09:00"
}

variable "snapshot_retention_limit" {
  description = "(Optional, Redis only) The number of days for which ElastiCache will retain automatic cache cluster snapshots before deleting them."
  type        = number
  default     = 7
}

variable "apply_immediately" {
  description = "(Optional) Specifies whether any modifications are applied immediately, or during the next maintenance window."
  type        = bool
  default     = false
}

variable "at_rest_encryption_enabled" {
  description = "(Optional) Whether to enable encryption at rest"
  type        = bool
  default     = false
}

variable "kms_key_arn" {
  description = "(Optional) The ARN of the key that you wish to use if encrypting at rest. If not supplied, uses service managed encryption. Can be specified only if at_rest_encryption_enabled = true"
  type        = string
  default     = null
}
