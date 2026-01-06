variable "environment" {
  description = "Environment name"
  type        = string
}

variable "azure_location" {
  description = "Azure region"
  type        = string
}

variable "common_tags" {
  description = "Common tags to apply to resources"
  type        = map(string)
  default     = {}
}