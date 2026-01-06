output "id" {
  value       = azurerm_data_factory.orchestration.id
  description = "Data Factory ID"
}

output "name" {
  value       = azurerm_data_factory.orchestration.name
  description = "Data Factory name"
}

output "principal_id" {
  value       = azurerm_data_factory.orchestration.identity[0].principal_id
  description = "Data Factory managed identity principal ID"
}

output "tenant_id" {
  value       = azurerm_data_factory.orchestration.identity[0].tenant_id
  description = "Data Factory managed identity tenant ID"
}

output "linked_service_id" {
  value       = azurerm_data_factory_linked_service_data_lake_storage_gen2.data_lake_link.id
  description = "Data Lake linked service ID"
}