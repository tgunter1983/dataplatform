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

variable "common_tags" {
  description = "Common tags to apply to resources"
  type        = map(string)
  default     = {}
}

variable "log_analytics_sku" {
  description = "Log Analytics workspace SKU"
  type        = string
  default     = "PerGB2018"
}

variable "retention_days" {
  description = "Number of days to retain logs"
  type        = number
  default     = 90
}

variable "enable_security_center" {
  description = "Enable Security Center solution"
  type        = bool
  default     = false
}

variable "enable_diagnostics" {
  description = "Enable diagnostic settings for the workspace"
  type        = bool
  default     = false
}