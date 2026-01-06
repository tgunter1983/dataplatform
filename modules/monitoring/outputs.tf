output "workspace_id" {
  value       = azurerm_log_analytics_workspace.monitoring.id
  description = "Log Analytics Workspace ID"
}

output "workspace_key" {
  value       = azurerm_log_analytics_workspace.monitoring.primary_shared_key
  description = "Log Analytics Workspace primary key"
  sensitive   = true
}

output "workspace_name" {
  value       = azurerm_log_analytics_workspace.monitoring.name
  description = "Log Analytics Workspace name"
}

output "workspace_customer_id" {
  value       = azurerm_log_analytics_workspace.monitoring.workspace_id
  description = "Log Analytics Workspace customer ID"
}