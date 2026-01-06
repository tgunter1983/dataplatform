terraform {
  required_version = ">= 1.0"
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.0"
    }
    google = {
      source  = "hashicorp/google"
      version = "~> 5.0"
    }
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "azurerm" {
  features {}
}

provider "google" {
  project = var.gcp_project_id
  region  = var.gcp_region
}

provider "aws" {
  region = var.aws_region
}

# Resource Group Module
module "resource_group" {
  source = "./modules/resource-group"
  
  environment     = var.environment
  azure_location  = var.azure_location
  common_tags     = var.common_tags
}

# Networking Module
module "networking" {
  source = "./modules/networking"
  
  environment         = var.environment
  azure_location      = var.azure_location
  resource_group_name = module.resource_group.name
  common_tags         = var.common_tags
}

# Data Lake Module
module "data_lake" {
  source = "./modules/data-lake"
  
  environment                = var.environment
  resource_group_name        = module.resource_group.name
  azure_location             = var.azure_location
  private_endpoint_subnet_id = module.networking.private_endpoints_subnet_id
  common_tags                = var.common_tags
}

# Data Factory Module
module "data_factory" {
  source = "./modules/data-factory"
  
  environment         = var.environment
  resource_group_name = module.resource_group.name
  azure_location      = var.azure_location
  data_lake_id        = module.data_lake.storage_account_id
  data_lake_endpoint  = module.data_lake.primary_dfs_endpoint
  common_tags         = var.common_tags
}

# Databricks Module
module "databricks" {
  source = "./modules/databricks"
  
  environment         = var.environment
  resource_group_name = module.resource_group.name
  azure_location      = var.azure_location
  vnet_id             = module.networking.vnet_id
  public_subnet_name  = module.networking.databricks_public_subnet_name
  private_subnet_name = module.networking.databricks_private_subnet_name
  data_lake_id        = module.data_lake.storage_account_id
  common_tags         = var.common_tags
}

# Security Module
module "security" {
  source = "./modules/security"
  
  environment         = var.environment
  resource_group_name = module.resource_group.name
  azure_location      = var.azure_location
  common_tags         = var.common_tags
}

# Monitoring Module
module "monitoring" {
  source = "./modules/monitoring"
  
  environment         = var.environment
  resource_group_name = module.resource_group.name
  azure_location      = var.azure_location
  common_tags         = var.common_tags
}

# Backup Module
module "backup" {
  source = "./modules/backup"
  
  environment         = var.environment
  resource_group_name = module.resource_group.name
  azure_location      = var.azure_location
  common_tags         = var.common_tags
}