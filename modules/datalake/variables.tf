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

variable "private_endpoint_subnet_id" {
  description = "Subnet ID for private endpoints"
  type        = string
}

variable "common_tags" {
  description = "Common tags to apply to resources"
  type        = map(string)
  default     = {}
}

variable "account_replication_type" {
  description = "Storage account replication type"
  type        = string
  default     = "ZRS"
}

variable "retention_days" {
  description = "Number of days to retain deleted blobs"
  type        = number
  default     = 30
}