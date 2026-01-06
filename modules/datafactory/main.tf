resource "azurerm_data_factory" "orchestration" {
  name                = "${var.environment}-healthcare-adf"
  location            = var.azure_location
  resource_group_name = var.resource_group_name
  
  identity {
    type = "SystemAssigned"
  }
  
  tags = var.common_tags
}

resource "azurerm_data_factory_linked_service_data_lake_storage_gen2" "data_lake_link" {
  name                 = "DataLakeLinkedService"
  data_factory_id      = azurerm_data_factory.orchestration.id
  url                  = var.data_lake_endpoint
  use_managed_identity = true
}

resource "azurerm_role_assignment" "adf_data_lake_contributor" {
  scope                = var.data_lake_id
  role_definition_name = "Storage Blob Data Contributor"
  principal_id         = azurerm_data_factory.orchestration.identity[0].principal_id
}

resource "azurerm_data_factory_integration_runtime_self_hosted" "self_hosted" {
  count = var.enable_self_hosted_ir ? 1 : 0
  
  name            = "${var.environment}-self-hosted-ir"
  data_factory_id = azurerm_data_factory.orchestration.id
}