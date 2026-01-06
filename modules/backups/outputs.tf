output "vault_id" {
  value       = azurerm_recovery_services_vault.backup.id
  description = "Recovery Services Vault ID"
}

output "vault_name" {
  value       = azurerm_recovery_services_vault.backup.name
  description = "Recovery Services Vault name"
}

output "backup_policy_id" {
  value       = var.enable_vm_backup_policy ? azurerm_backup_policy_vm.daily[0].id : null
  description = "VM backup policy ID"
}