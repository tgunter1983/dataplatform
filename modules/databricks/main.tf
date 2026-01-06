resource "azurerm_databricks_workspace" "analytics_hub" {
  name                = "${var.environment}-healthcare-databricks"
  resource_group_name = var.resource_group_name
  location            = var.azure_location
  sku                 = var.databricks_sku
  
  custom_parameters {
    no_public_ip                                         = true
    virtual_network_id                                   = var.vnet_id
    public_subnet_name                                   = var.public_subnet_name
    private_subnet_name                                  = var.private_subnet_name
    public_subnet_network_security_group_association_id  = var.public_subnet_nsg_association_id
    private_subnet_network_security_group_association_id = var.private_subnet_nsg_association_id
  }
  
  tags = var.common_tags
}

resource "azurerm_role_assignment" "databricks_data_lake_contributor" {
  scope                = var.data_lake_id
  role_definition_name = "Storage Blob Data Contributor"
  principal_id         = azurerm_databricks_workspace.analytics_hub.storage_account_identity[0].principal_id
}