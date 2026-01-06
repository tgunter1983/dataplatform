resource "azurerm_storage_account" "data_lake" {
  name                     = "${var.environment}healthcaredl"
  resource_group_name      = var.resource_group_name
  location                 = var.azure_location
  account_tier             = "Standard"
  account_replication_type = "ZRS"
  account_kind             = "StorageV2"
  is_hns_enabled           = true
  
  blob_properties {
    versioning_enabled = true
    
    delete_retention_policy {
      days = 30
    }
    
    container_delete_retention_policy {
      days = 30
    }
  }
  
  network_rules {
    default_action = "Deny"
    bypass         = ["AzureServices"]
  }
  
  tags = var.common_tags
}

resource "azurerm_storage_data_lake_gen2_filesystem" "bronze" {
  name               = "bronze"
  storage_account_id = azurerm_storage_account.data_lake.id
  
  properties = {
    description = "Bronze layer - Raw data ingestion"
  }
}

resource "azurerm_storage_data_lake_gen2_filesystem" "silver" {
  name               = "silver"
  storage_account_id = azurerm_storage_account.data_lake.id
  
  properties = {
    description = "Silver layer - Cleaned and validated data"
  }
}

resource "azurerm_storage_data_lake_gen2_filesystem" "gold" {
  name               = "gold"
  storage_account_id = azurerm_storage_account.data_lake.id
  
  properties = {
    description = "Gold layer - Business-ready aggregated data"
  }
}

resource "azurerm_private_endpoint" "data_lake" {
  name                = "${var.environment}-datalake-pe"
  location            = var.azure_location
  resource_group_name = var.resource_group_name
  subnet_id           = var.private_endpoint_subnet_id
  
  private_service_connection {
    name                           = "datalake-privateserviceconnection"
    private_connection_resource_id = azurerm_storage_account.data_lake.id
    subresource_names              = ["dfs"]
    is_manual_connection           = false
  }
  
  tags = var.common_tags
}