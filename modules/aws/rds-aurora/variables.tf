variable "common_tags" {
  description = "(Optional) Common tags"
  type        = map(string)
  default     = null
}

variable "subnet_ids" {
  description = "(Required) Subnet IDs"
  type        = list(string)
}

variable "db_subnet_group_tags" {
  description = "(Optional) DB Subnet group tags"
  type        = map(string)
  default     = null
}

variable "db_parameter_group_tags" {
  description = "(Optional) DB Parameter group tags"
  type        = map(string)
  default     = null
}

variable "cluster_parameter_group_tags" {
  description = "(Optional) Cluster Parameter group tags"
  type        = map(string)
  default     = null
}

variable "db_parameters" {
  description = "(Optional) DB Parameters"
  type        = list(map(string))
  default     = []
}

variable "cluster_parameters" {
  description = "(Optional) RDS Cluster Parameters"
  type        = list(map(string))
  default     = []
}

variable "cluster_parameter_group_description" {
  description = "(Optional) RDS Cluster Parameters description"
  type        = string
  default     = "RDS Aurora Cluster Parameter group"
}

variable "family" {
  description = "(Required) The family of the DB parameter group"
  type        = string
}

variable "db_subnet_group_description" {
  description = "(Optional) DB Subnet group description"
  type        = string
  default     = "RDS Aurora DB Subnet group"
}

variable "db_parameter_group_description" {
  description = "(Optional) DB Parameter group description"
  type        = string
  default     = "RDS Aurora DB Parameter group"
}

variable "cluster_name" {
  description = "(Required) The cluster identifier"
  type        = string
}

variable "engine" {
  description = "(Optional) The name of the database engine to be used for this DB cluster. Valid Values: aurora, aurora-mysql, aurora-postgresql"
  type        = string
  default     = "aurora-mysql"
}

variable "engine_version" {
  description = "(Required) The database engine version. Updating this argument results in an outage. See the Aurora MySQL and Aurora Postgres documentation for your configured engine to determine this value"
  type        = string
}

variable "database_name" {
  description = "(Required) The database name"
  type        = string
}

variable "master_username" {
  description = "(Required) The master username for the database"
  type        = string
}

variable "master_password" {
  description = "(Required) The master password for the database"
  type        = string
}

variable "availability_zones" {
  description = "(Required) A list of EC2 Availability Zones for the DB cluster storage where DB cluster instances can be created"
  type        = list(string)
}

variable "backup_retention_period" {
  description = "(Optional) The days to retain backups for. Default 7"
  type        = number
  default     = 7
}

variable "preferred_backup_window" {
  description = "(Optional) The daily time range during which automated backups are created if automated backups are enabled using the BackupRetentionPeriod parameter.Time in UTC."
  type        = string
  default     = "04:00-09:00"
}

variable "preferred_maintenance_window" {
  description = "(Optional) The weekly time range during which system maintenance can occur, in (UTC)"
  type        = string
  default     = "sun:04:00-sun:04:30"
}

variable "vpc_security_group_ids" {
  description = "(Required) List of VPC security groups to associate with the Cluster"
  type        = list(string)
}

variable "port" {
  description = "(Optional) DB Port"
  type        = number
  default     = 3306
}

variable "skip_final_snapshot" {
  description = "(Optional) Determines whether a final DB snapshot is created before the DB cluster is deleted"
  type        = bool
  default     = false
}

variable "apply_immediately" {
  description = "(Optional) Specifies whether any cluster modifications are applied immediately, or during the next maintenance window."
  type        = bool
  default     = false
}

variable "storage_encrypted" {
  description = "(Optional) Specifies whether the DB cluster is encrypted. The default is false"
  type        = bool
  default     = false
}

variable "kms_key_arn" {
  description = "(Optional) The ARN for the KMS encryption key. When specifying kms_key_id, storage_encrypted needs to be set to true"
  type        = string
  default     = null
}

variable "cluster_tags" {
  description = "(Optional) Cluster tags"
  type        = map(string)
  default     = null
}

variable "instances" {
  description = "(Required) Number of instance"
  type        = number
}

variable "instance_class" {
  description = "(Required) Instance class"
  type        = string
}

variable "performance_insights_enabled" {
  description = "(Optional) Specifies whether Performance Insights is enabled or not."
  type        = bool
  default     = false
}

variable "publicly_accessible" {
  description = "(Optional) Bool to control if instance is publicly accessible."
  type        = bool
  default     = false
}
