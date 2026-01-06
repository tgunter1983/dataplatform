output "name" {
  value       = azurerm_resource_group.healthcare_platform.name
  description = "Resource Group name"
}

output "location" {
  value       = azurerm_resource_group.healthcare_platform.location
  description = "Resource Group location"
}

output "id" {
  value       = azurerm_resource_group.healthcare_platform.id
  description = "Resource Group ID"
}