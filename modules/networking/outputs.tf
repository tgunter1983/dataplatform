output "vnet_id" {
  value       = azurerm_virtual_network.healthcare_vnet.id
  description = "Virtual Network ID"
}

output "vnet_name" {
  value       = azurerm_virtual_network.healthcare_vnet.name
  description = "Virtual Network name"
}

output "databricks_public_subnet_id" {
  value       = azurerm_subnet.databricks_public.id
  description = "Databricks public subnet ID"
}

output "databricks_public_subnet_name" {
  value       = azurerm_subnet.databricks_public.name
  description = "Databricks public subnet name"
}

output "databricks_private_subnet_id" {
  value       = azurerm_subnet.databricks_private.id
  description = "Databricks private subnet ID"
}

output "databricks_private_subnet_name" {
  value       = azurerm_subnet.databricks_private.name
  description = "Databricks private subnet name"
}

output "private_endpoints_subnet_id" {
  value       = azurerm_subnet.private_endpoints.id
  description = "Private endpoints subnet ID"
}

output "nsg_id" {
  value       = azurerm_network_security_group.healthcare_nsg.id
  description = "Network Security Group ID"
}