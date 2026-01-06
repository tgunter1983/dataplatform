variable "environment" {
  description = "Environment name"
  type        = string
}

variable "azure_location" {
  description = "Azure region"
  type        = string
}

variable "resource_group_name" {
  description = "Resource Group name"
  type        = string
}

variable "data_lake_id" {
  description = "Data Lake Storage Account ID"
  type        = string
}

variable "data_lake_endpoint" {
  description = "Data Lake primary DFS endpoint"
  type        = string
}

variable "common_tags" {
  description = "Common tags to apply to resources"
  type        = map(string)
  default     = {}
}

variable "enable_self_hosted_ir" {
  description = "Enable self-hosted integration runtime"
  type        = bool
  default     = false
}