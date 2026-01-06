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

variable "vnet_id" {
  description = "Virtual Network ID"
  type        = string
}

variable "public_subnet_name" {
  description = "Public subnet name for Databricks"
  type        = string
}

variable "private_subnet_name" {
  description = "Private subnet name for Databricks"
  type        = string
}

variable "public_subnet_nsg_association_id" {
  description = "Public subnet NSG association ID"
  type        = string
  default     = null
}

variable "private_subnet_nsg_association_id" {
  description = "Private subnet NSG association ID"
  type        = string
  default     = null
}

variable "data_lake_id" {
  description = "Data Lake Storage Account ID"
  type        = string
}

variable "common_tags" {
  description = "Common tags to apply to resources"
  type        = map(string)
  default     = {}
}

variable "databricks_sku" {
  description = "Databricks SKU (standard, premium, trial)"
  type        = string
  default     = "premium"
}