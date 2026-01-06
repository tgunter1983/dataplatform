output "resource_group_name" {
  value       = module.resource_group.name
  description = "Resource Group name"
}

output "resource_group_id" {
  value       = module.resource_group.id
  description = "Resource Group ID"
}

output "data_factory_id" {
  value       = module.data_factory.id
  description = "Azure Data Factory ID"
}

output "data_factory_name" {
  value       = module.data_factory.name
  description = "Azure Data Factory name"
}

output "databricks_workspace_url" {
  value       = module.databricks.workspace_url
  description = "Databricks workspace URL"
}

output "databricks_workspace_id" {
  value       = module.databricks.workspace_id
  description = "Databricks workspace ID"
}

output "data_lake_endpoint" {
  value       = module.data_lake.primary_dfs_endpoint
  description = "Data Lake primary endpoint"
}

output "data_lake_id" {
  value       = module.data_lake.storage_account_id
  description = "Data Lake Storage Account ID"
}

output "key_vault_uri" {
  value       = module.security.key_vault_uri
  description = "Key Vault URI"
}

output "key_vault_id" {
  value       = module.security.key_vault_id
  description = "Key Vault ID"
}

output "vnet_id" {
  value       = module.networking.vnet_id
  description = "Virtual Network ID"
}

output "log_analytics_workspace_id" {
  value       = module.monitoring.workspace_id
  description = "Log Analytics Workspace ID"
}

output "recovery_vault_id" {
  value       = module.backup.vault_id
  description = "Recovery Services Vault ID"
}