output "workspace_id" {
  value       = azurerm_databricks_workspace.analytics_hub.id
  description = "Databricks workspace ID"
}

output "workspace_url" {
  value       = azurerm_databricks_workspace.analytics_hub.workspace_url
  description = "Databricks workspace URL"
}

output "workspace_name" {
  value       = azurerm_databricks_workspace.analytics_hub.name
  description = "Databricks workspace name"
}

output "managed_resource_group_id" {
  value       = azurerm_databricks_workspace.analytics_hub.managed_resource_group_id
  description = "Databricks managed resource group ID"
}