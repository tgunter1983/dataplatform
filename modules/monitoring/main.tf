resource "azurerm_log_analytics_workspace" "monitoring" {
  name                = "${var.environment}-healthcare-logs"
  location            = var.azure_location
  resource_group_name = var.resource_group_name
  sku                 = var.log_analytics_sku
  retention_in_days   = var.retention_days
  
  tags = var.common_tags
}

resource "azurerm_log_analytics_solution" "security_center" {
  count = var.enable_security_center ? 1 : 0
  
  solution_name         = "SecurityCenterFree"
  location              = var.azure_location
  resource_group_name   = var.resource_group_name
  workspace_resource_id = azurerm_log_analytics_workspace.monitoring.id
  workspace_name        = azurerm_log_analytics_workspace.monitoring.name
  
  plan {
    publisher = "Microsoft"
    product   = "OMSGallery/SecurityCenterFree"
  }
}

resource "azurerm_monitor_diagnostic_setting" "workspace" {
  count = var.enable_diagnostics ? 1 : 0
  
  name                       = "${var.environment}-workspace-diagnostics"
  target_resource_id         = azurerm_log_analytics_workspace.monitoring.id
  log_analytics_workspace_id = azurerm_log_analytics_workspace.monitoring.id
  
  enabled_log {
    category = "Audit"
  }
  
  metric {
    category = "AllMetrics"
  }
}