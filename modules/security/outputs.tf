output "key_vault_id" {
  value       = azurerm_key_vault.security.id
  description = "Key Vault ID"
}

output "key_vault_uri" {
  value       = azurerm_key_vault.security.vault_uri
  description = "Key Vault URI"
}

output "key_vault_name" {
  value       = azurerm_key_vault.security.name
  description = "Key Vault name"
}

output "tenant_id" {
  value       = data.azurerm_client_config.current.tenant_id
  description = "Azure AD Tenant ID"
}