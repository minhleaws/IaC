variable "name_prefix" {
  description = "(Required) Name prefix for aws resources"
  type        = string
}

variable "common_tags" {
  description = "(Optional) Common tags"
  type        = map(string)
  default     = null
}

variable "vpc_cidr_block" {
  description = "(Required) The IPv4 CIDR block for the VPC"
  type        = string
}

variable "vpc_tags" {
  description = "(Optional) Specify VPC tags"
  type        = map(string)
  default     = null
}

variable "enable_dns_hostnames" {
  description = "(Optional) A boolean flag to enable/disable DNS hostnames in the VPC. Defaults is true"
  type        = bool
  default     = true
}

variable "azs" {
  description = "(Required) List of AZs"
  type        = list(string)
}

variable "public_subnet_tags" {
  description = "(Optional) Public subnet tags"
  type        = map(string)
  default     = null
}

variable "public_subnet_cidrs" {
  description = "(Required) Public subnet CIRDs"
  type        = list(string)
}

variable "private_subnet_cidrs" {
  description = "(Required) Private subnet CIRDs"
  type        = list(string)
}

variable "private_subnet_tags" {
  description = "(Optional) Private subnet tags"
  type        = map(string)
  default     = null
}

variable "igw_tags" {
  description = "(Optional) InternetGW tags"
  type        = map(string)
  default     = null
}

variable "natgw_eip_tags" {
  description = "(Optional) NatGW EIP tags"
  type        = map(string)
  default     = null
}

variable "natgw_tags" {
  description = "(Optional) NatGW tags"
  type        = map(string)
  default     = null
}

variable "rtb_public_subnet_tags" {
  description = "(Optional) Route TB public subnet tags"
  type        = map(string)
  default     = null
}

variable "rtb_private_subnet_tags" {
  description = "(Optional) Route TB private subnet tags"
  type        = map(string)
  default     = null
}

variable "nacl_public_tags" {
  description = "(Optional) NACL public subnet tags"
  type        = map(string)
  default     = null
}

variable "nacl_private_tags" {
  description = "(Optional) NACL private subnet tags"
  type        = map(string)
  default     = null
}

variable "nacl_public_subnet_rules" {
  description = "(Required) NACL rule for public subnet"
  type        = list(map(string))
}

variable "nacl_private_subnet_rules" {
  description = "(Required) NACL rule for public subnet"
  type        = list(map(string))
}

variable "natgw_multi_az" {
  description = "(Optional) NatGW per AZ"
  type        = bool
  default     = false
}
