variable "caf_prefixes" {
  type        = list(string)
  default     = []
  description = "Prefixes to use for caf naming. Only required when create_endpoints is true."
}

variable "custom_tags" {
  type        = map(string)
  default     = {}
  description = "The custom tags to add on the resource."
}

variable "create_endpoints" {
  type        = bool
  default     = true
  description = "Must the module create private enpoints to the server"
}

variable "description" {
  type        = string
  description = "An optional description tag"
  default     = ""
}

variable "disaster_recovery" {
  type        = bool
  description = "Deploy disaster recovery infrastructure. Only specify if FOG is false."
  default     = false
}

variable "fog_enabled" {
  type        = bool
  description = "Is the database part of a failover group (fog). If set to yes it will return the highly available endpoint and secondary endpoint."
  default     = false
}

variable "endpoint_subnet_id" {
  type        = string
  description = "The subnet where to create the endpoint"
  default     = "endpoint_subnet_id not defined"
}

variable "environment" {
  type = string
}

variable "private_dns_zone_id" {
  type        = string
  description = "The private dns zone id where to create the a record for the private endpoint"
  default     = "private_dns_zone_id not defined"
}

variable "region_main" {
  type        = string
  description = "The tag main region value. Only if FOG is enabled."
  default     = "MAIN"
}

variable "region_dr" {
  type        = string
  description = "The tag region value. Only if FOG is enabled."
  default     = "DISASTER_RECOVERY"
}

variable "resource_group_name" {
  type        = string
  description = "The Private Endpoint resource group name. Only required when create_endpoints is true."
  default     = null
}

variable "targetdb_project" {
  type        = string
  description = "The target database A_PROJECT tag"
  default     = "OPT"
}

variable "targetserver_usage" {
  type        = string
  description = "The target server SERVER_USAGE tag"
}

variable "dns_zone_group_name_use_caf" {
  type        = bool
  description = "(optional) Use azurecaf_name for Private DNS Zone Group name"
  default     = false
}
