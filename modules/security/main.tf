data "azurerm_client_config" "current" {}

resource "azurerm_key_vault" "security" {
  name                       = "${var.environment}-hc-kv"
  location                   = var.azure_location
  resource_group_name        = var.resource_group_name
  tenant_id                  = data.azurerm_client_config.current.tenant_id
  sku_name                   = "premium"
  soft_delete_retention_days = var.soft_delete_retention_days
  purge_protection_enabled   = var.purge_protection_enabled
  
  network_acls {
    default_action = "Deny"
    bypass         = "AzureServices"
  }
  
  tags = var.common_tags
}

# Access policy for current user/service principal
resource "azurerm_key_vault_access_policy" "admin" {
  key_vault_id = azurerm_key_vault.security.id
  tenant_id    = data.azurerm_client_config.current.tenant_id
  object_id    = data.azurerm_client_config.current.object_id
  
  key_permissions = [
    "Get", "List", "Create", "Delete", "Update", "Import", "Backup", "Restore", "Recover"
  ]
  
  secret_permissions = [
    "Get", "List", "Set", "Delete", "Backup", "Restore", "Recover"
  ]
  
  certificate_permissions = [
    "Get", "List", "Create", "Delete", "Update", "Import", "Backup", "Restore", "Recover"
  ]
}