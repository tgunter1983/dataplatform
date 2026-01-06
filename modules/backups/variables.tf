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

variable "vault_sku" {
  description = "Recovery Services Vault SKU"
  type        = string
  default     = "Standard"
}

variable "soft_delete_enabled" {
  description = "Enable soft delete for backup vault"
  type        = bool
  default     = true
}

variable "enable_vm_backup_policy" {
  description = "Enable VM backup policy"
  type        = bool
  default     = false
}

variable "backup_timezone" {
  description = "Timezone for backup schedule"
  type        = string
  default     = "UTC"
}

variable "backup_time" {
  description = "Time of day for backup (HH:MM format)"
  type        = string
  default     = "23:00"
}

variable "daily_retention_count" {
  description = "Number of daily backups to retain"
  type        = number
  default     = 7
}

variable "weekly_retention_count" {
  description = "Number of weekly backups to retain"
  type        = number
  default     = 4
}

variable "monthly_retention_count" {
  description = "Number of monthly backups to retain"
  type        = number
  default     = 12
}

variable "yearly_retention_count" {
  description = "Number of yearly backups to retain"
  type        = number
  default     = 1
}