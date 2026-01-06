resource "azurerm_resource_group" "healthcare_platform" {
  name     = "${var.environment}-healthcare-platform-rg"
  location = var.azure_location
  tags     = var.common_tags
}