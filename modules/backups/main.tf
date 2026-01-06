resource "azurerm_recovery_services_vault" "backup" {
  name                = "${var.environment}-healthcare-rsv"
  location            = var.azure_location
  resource_group_name = var.resource_group_name
  sku                 = var.vault_sku
  soft_delete_enabled = var.soft_delete_enabled
  
  tags = var.common_tags
}

resource "azurerm_backup_policy_vm" "daily" {
  count = var.enable_vm_backup_policy ? 1 : 0
  
  name                = "${var.environment}-daily-backup-policy"
  resource_group_name = var.resource_group_name
  recovery_vault_name = azurerm_recovery_services_vault.backup.name
  
  timezone = var.backup_timezone
  
  backup {
    frequency = "Daily"
    time      = var.backup_time
  }
  
  retention_daily {
    count = var.daily_retention_count
  }
  
  retention_weekly {
    count    = var.weekly_retention_count
    weekdays = ["Sunday"]
  }
  
  retention_monthly {
    count    = var.monthly_retention_count
    weekdays = ["Sunday"]
    weeks    = ["First"]
  }
  
  retention_yearly {
    count    = var.yearly_retention_count
    weekdays = ["Sunday"]
    weeks    = ["First"]
    months   = ["January"]
  }
}