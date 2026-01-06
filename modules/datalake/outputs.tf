output "storage_account_id" {
  value       = azurerm_storage_account.data_lake.id
  description = "Storage Account ID"
}

output "storage_account_name" {
  value       = azurerm_storage_account.data_lake.name
  description = "Storage Account name"
}

output "primary_dfs_endpoint" {
  value       = azurerm_storage_account.data_lake.primary_dfs_endpoint
  description = "Primary DFS endpoint"
}

output "primary_blob_endpoint" {
  value       = azurerm_storage_account.data_lake.primary_blob_endpoint
  description = "Primary Blob endpoint"
}

output "bronze_filesystem_id" {
  value       = azurerm_storage_data_lake_gen2_filesystem.bronze.id
  description = "Bronze filesystem ID"
}

output "silver_filesystem_id" {
  value       = azurerm_storage_data_lake_gen2_filesystem.silver.id
  description = "Silver filesystem ID"
}

output "gold_filesystem_id" {
  value       = azurerm_storage_data_lake_gen2_filesystem.gold.id
  description = "Gold filesystem ID"
}

output "private_endpoint_id" {
  value       = azurerm_private_endpoint.data_lake.id
  description = "Private endpoint ID"
}