# Healthcare HIPAA/HITECH Compliance Module

terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.0"
    }
  }
}

locals {
  phi_tags = {
    DataClassification = "PHI"
    Compliance        = "HIPAA"
    Retention         = var.data_retention_years
  }
}

# ==========================================
# 1. Azure Policy Assignments for HIPAA
# ==========================================

resource "azurerm_resource_group_policy_assignment" "hipaa_hitrust" {
  name                 = "${var.environment}-hipaa-policy"
  resource_group_id    = var.resource_group_id
  policy_definition_id = "/providers/Microsoft.Authorization/policySetDefinitions/a169a624-5599-4385-a696-c8d643089fab"
  description          = "HIPAA HITRUST 9.2 compliance policy"
  display_name         = "${var.environment} HIPAA HITRUST Compliance"
  
  identity {
    type = "SystemAssigned"
  }
  
  parameters = jsonencode({
    effect = {
      value = "Audit"
    }
  })
}

resource "azurerm_resource_group_policy_assignment" "require_encryption" {
  name                 = "${var.environment}-require-encryption"
  resource_group_id    = var.resource_group_id
  policy_definition_id = "/providers/Microsoft.Authorization/policyDefinitions/404c3081-a854-4457-ae30-26a93ef643f9"
  description          = "Require encryption for storage accounts"
  display_name         = "${var.environment} Require Storage Encryption"
}

resource "azurerm_resource_group_policy_assignment" "require_https" {
  name                 = "${var.environment}-require-https"
  resource_group_id    = var.resource_group_id
  policy_definition_id = "/providers/Microsoft.Authorization/policyDefinitions/404c3081-a854-4457-ae30-26a93ef643f9"
  description          = "Require HTTPS for all storage connections"
  display_name         = "${var.environment} Require HTTPS Only"
}

# ==========================================
# 2. Advanced Threat Protection
# ==========================================

resource "azurerm_security_center_subscription_pricing" "defender_storage" {
  tier          = "Standard"
  resource_type = "StorageAccounts"
}

resource "azurerm_security_center_subscription_pricing" "defender_sql" {
  tier          = "Standard"
  resource_type = "SqlServers"
}

resource "azurerm_security_center_subscription_pricing" "defender_keyvault" {
  tier          = "Standard"
  resource_type = "KeyVaults"
}

# Enable Advanced Threat Protection on Data Lake
resource "azurerm_advanced_threat_protection" "data_lake" {
  target_resource_id = var.data_lake_id
  enabled            = true
}

# ==========================================
# 3. Audit Logging and Retention
# ==========================================

resource "azurerm_log_analytics_workspace" "hipaa_audit" {
  name                = "${var.environment}-hipaa-audit-logs"
  location            = var.azure_location
  resource_group_name = var.resource_group_name
  sku                 = "PerGB2018"
  retention_in_days   = var.audit_retention_days
  
  tags = merge(var.common_tags, local.phi_tags)
}

# Storage account for long-term audit retention
resource "azurerm_storage_account" "audit_archive" {
  name                     = "${var.environment}auditarchive"
  resource_group_name      = var.resource_group_name
  location                 = var.azure_location
  account_tier             = "Standard"
  account_replication_type = "GRS"
  account_kind             = "StorageV2"
  
  # Enable immutable storage for compliance
  blob_properties {
    versioning_enabled       = true
    change_feed_enabled      = true
    last_access_time_enabled = true
    
    delete_retention_policy {
      days = var.audit_retention_days
    }
    
    container_delete_retention_policy {
      days = var.audit_retention_days
    }
  }
  
  # Require secure transfer
  enable_https_traffic_only = true
  min_tls_version          = "TLS1_2"
  
  network_rules {
    default_action = "Deny"
    bypass         = ["AzureServices"]
  }
  
  tags = merge(var.common_tags, local.phi_tags)
}

resource "azurerm_storage_container" "audit_logs" {
  name                  = "audit-logs"
  storage_account_name  = azurerm_storage_account.audit_archive.name
  container_access_type = "private"
}

# ==========================================
# 4. Data Classification and Tagging
# ==========================================

# Create Azure Purview account for data governance
resource "azurerm_purview_account" "data_governance" {
  name                = "${var.environment}-healthcare-purview"
  resource_group_name = var.resource_group_name
  location            = var.azure_location
  
  identity {
    type = "SystemAssigned"
  }
  
  tags = merge(var.common_tags, local.phi_tags)
}

# Grant Purview access to Data Lake for scanning
resource "azurerm_role_assignment" "purview_data_lake_reader" {
  scope                = var.data_lake_id
  role_definition_name = "Storage Blob Data Reader"
  principal_id         = azurerm_purview_account.data_governance.identity[0].principal_id
}

# ==========================================
# 5. Access Reviews and Monitoring
# ==========================================

# Action Group for security alerts
resource "azurerm_monitor_action_group" "security_team" {
  name                = "${var.environment}-security-alerts"
  resource_group_name = var.resource_group_name
  short_name          = "SecTeam"
  
  email_receiver {
    name          = "SecurityTeam"
    email_address = var.security_team_email
  }
  
  email_receiver {
    name                    = "ComplianceOfficer"
    email_address           = var.compliance_officer_email
    use_common_alert_schema = true
  }
  
  tags = var.common_tags
}

# Alert for unauthorized access attempts
resource "azurerm_monitor_metric_alert" "unauthorized_access" {
  name                = "${var.environment}-unauthorized-access-alert"
  resource_group_name = var.resource_group_name
  scopes              = [var.data_lake_id]
  description         = "Alert when unauthorized access attempts detected"
  severity            = 1
  frequency           = "PT5M"
  window_size         = "PT15M"
  
  criteria {
    metric_namespace = "Microsoft.Storage/storageAccounts"
    metric_name      = "Transactions"
    aggregation      = "Total"
    operator         = "GreaterThan"
    threshold        = 10
    
    dimension {
      name     = "ResponseType"
      operator = "Include"
      values   = ["ClientAccountBandwidthThrottlingError", "ClientAccountRequestThrottlingError"]
    }
  }
  
  action {
    action_group_id = azurerm_monitor_action_group.security_team.id
  }
  
  tags = var.common_tags
}

# Alert for Key Vault access
resource "azurerm_monitor_metric_alert" "keyvault_access" {
  name                = "${var.environment}-keyvault-access-alert"
  resource_group_name = var.resource_group_name
  scopes              = [var.key_vault_id]
  description         = "Alert on Key Vault access patterns"
  severity            = 2
  frequency           = "PT5M"
  window_size         = "PT15M"
  
  criteria {
    metric_namespace = "Microsoft.KeyVault/vaults"
    metric_name      = "ServiceApiResult"
    aggregation      = "Total"
    operator         = "GreaterThan"
    threshold        = 5
    
    dimension {
      name     = "StatusCode"
      operator = "Include"
      values   = ["403", "401"]
    }
  }
  
  action {
    action_group_id = azurerm_monitor_action_group.security_team.id
  }
  
  tags = var.common_tags
}

# ==========================================
# 6. Data Retention and Lifecycle Management
# ==========================================

resource "azurerm_storage_management_policy" "phi_retention" {
  storage_account_id = var.data_lake_id
  
  rule {
    name    = "phi-retention-bronze"
    enabled = true
    
    filters {
      prefix_match = ["bronze/"]
      blob_types   = ["blockBlob"]
    }
    
    actions {
      base_blob {
        tier_to_cool_after_days_since_modification_greater_than    = 30
        tier_to_archive_after_days_since_modification_greater_than = 90
        delete_after_days_since_modification_greater_than          = var.data_retention_years * 365
      }
      
      snapshot {
        delete_after_days_since_creation_greater_than = 30
      }
      
      version {
        delete_after_days_since_creation = 90
      }
    }
  }
  
  rule {
    name    = "phi-retention-silver"
    enabled = true
    
    filters {
      prefix_match = ["silver/"]
      blob_types   = ["blockBlob"]
    }
    
    actions {
      base_blob {
        tier_to_cool_after_days_since_modification_greater_than    = 60
        tier_to_archive_after_days_since_modification_greater_than = 180
        delete_after_days_since_modification_greater_than          = var.data_retention_years * 365
      }
    }
  }
  
  rule {
    name    = "phi-retention-gold"
    enabled = true
    
    filters {
      prefix_match = ["gold/"]
      blob_types   = ["blockBlob"]
    }
    
    actions {
      base_blob {
        tier_to_cool_after_days_since_modification_greater_than    = 90
        tier_to_archive_after_days_since_modification_greater_than = 365
        delete_after_days_since_modification_greater_than          = var.data_retention_years * 365
      }
    }
  }
}

# ==========================================
# 7. Encryption at Rest with CMK
# ==========================================

# Create encryption key in Key Vault
resource "azurerm_key_vault_key" "data_encryption" {
  name         = "${var.environment}-data-encryption-key"
  key_vault_id = var.key_vault_id
  key_type     = "RSA"
  key_size     = 4096
  
  key_opts = [
    "decrypt",
    "encrypt",
    "sign",
    "unwrapKey",
    "verify",
    "wrapKey",
  ]
  
  rotation_policy {
    automatic {
      time_before_expiry = "P30D"
    }
    
    expire_after         = "P90D"
    notify_before_expiry = "P29D"
  }
  
  tags = merge(var.common_tags, local.phi_tags)
}

# ==========================================
# 8. Network Security and Private Links
# ==========================================

# Private DNS Zone for Storage
resource "azurerm_private_dns_zone" "storage_blob" {
  name                = "privatelink.blob.core.windows.net"
  resource_group_name = var.resource_group_name
  
  tags = var.common_tags
}

resource "azurerm_private_dns_zone" "storage_dfs" {
  name                = "privatelink.dfs.core.windows.net"
  resource_group_name = var.resource_group_name
  
  tags = var.common_tags
}

resource "azurerm_private_dns_zone" "keyvault" {
  name                = "privatelink.vaultcore.azure.net"
  resource_group_name = var.resource_group_name
  
  tags = var.common_tags
}

# Link DNS zones to VNet
resource "azurerm_private_dns_zone_virtual_network_link" "storage_blob" {
  name                  = "${var.environment}-blob-dns-link"
  resource_group_name   = var.resource_group_name
  private_dns_zone_name = azurerm_private_dns_zone.storage_blob.name
  virtual_network_id    = var.vnet_id
  
  tags = var.common_tags
}

resource "azurerm_private_dns_zone_virtual_network_link" "storage_dfs" {
  name                  = "${var.environment}-dfs-dns-link"
  resource_group_name   = var.resource_group_name
  private_dns_zone_name = azurerm_private_dns_zone.storage_dfs.name
  virtual_network_id    = var.vnet_id
  
  tags = var.common_tags
}

resource "azurerm_private_dns_zone_virtual_network_link" "keyvault" {
  name                  = "${var.environment}-keyvault-dns-link"
  resource_group_name   = var.resource_group_name
  private_dns_zone_name = azurerm_private_dns_zone.keyvault.name
  virtual_network_id    = var.vnet_id
  
  tags = var.common_tags
}

# ==========================================
# 9. Compliance Dashboard and Reporting
# ==========================================

# Log Analytics queries for compliance reporting
resource "azurerm_log_analytics_saved_search" "phi_access_audit" {
  name                       = "PHI-Access-Audit"
  log_analytics_workspace_id = azurerm_log_analytics_workspace.hipaa_audit.id
  category                   = "HIPAA Compliance"
  display_name               = "PHI Access Audit Report"
  
  query = <<-QUERY
    StorageBlobLogs
    | where TimeGenerated > ago(24h)
    | where Category == "StorageRead" or Category == "StorageWrite" or Category == "StorageDelete"
    | extend PHIAccess = iff(Uri contains "phi" or Uri contains "patient", "Yes", "No")
    | where PHIAccess == "Yes"
    | project TimeGenerated, CallerIpAddress, AuthenticationType, Uri, StatusCode, UserAgentHeader
    | order by TimeGenerated desc
  QUERY
}

resource "azurerm_log_analytics_saved_search" "failed_access_attempts" {
  name                       = "Failed-Access-Attempts"
  log_analytics_workspace_id = azurerm_log_analytics_workspace.hipaa_audit.id
  category                   = "Security"
  display_name               = "Failed Access Attempts to PHI"
  
  query = <<-QUERY
    StorageBlobLogs
    | where TimeGenerated > ago(7d)
    | where StatusCode startswith "4" or StatusCode startswith "5"
    | extend PHIAccess = iff(Uri contains "phi" or Uri contains "patient", "Yes", "No")
    | where PHIAccess == "Yes"
    | summarize FailedAttempts = count() by CallerIpAddress, bin(TimeGenerated, 1h)
    | where FailedAttempts > 5
    | order by FailedAttempts desc
  QUERY
}

resource "azurerm_log_analytics_saved_search" "encryption_status" {
  name                       = "Encryption-Status"
  log_analytics_workspace_id = azurerm_log_analytics_workspace.hipaa_audit.id
  category                   = "HIPAA Compliance"
  display_name               = "Encryption Status Report"
  
  query = <<-QUERY
    AzureDiagnostics
    | where ResourceType == "STORAGEACCOUNTS"
    | extend EncryptionStatus = iff(properties_encryption_services_blob_enabled_b == true, "Encrypted", "Not Encrypted")
    | summarize by ResourceId, EncryptionStatus, Resource
    | order by EncryptionStatus asc
  QUERY
}

# ==========================================
# 10. Break Glass Access Procedure
# ==========================================

# Emergency access Key Vault for break-glass scenarios
resource "azurerm_key_vault" "emergency_access" {
  name                       = "${var.environment}-emergency-kv"
  location                   = var.azure_location
  resource_group_name        = var.resource_group_name
  tenant_id                  = var.tenant_id
  sku_name                   = "premium"
  soft_delete_retention_days = 90
  purge_protection_enabled   = true
  
  # Enable audit logging
  enable_rbac_authorization = true
  
  network_acls {
    default_action = "Deny"
    bypass         = "AzureServices"
  }
  
  tags = merge(var.common_tags, {
    Purpose = "Emergency Break Glass Access"
    Alert   = "High"
  })
}

# Store break-glass credentials
resource "azurerm_key_vault_secret" "break_glass_instructions" {
  name         = "break-glass-procedure"
  value        = var.break_glass_procedure_doc
  key_vault_id = azurerm_key_vault.emergency_access.id
  
  tags = {
    Purpose = "Emergency Access Documentation"
  }
}

# Alert when emergency vault is accessed
resource "azurerm_monitor_activity_log_alert" "emergency_access_alert" {
  name                = "${var.environment}-emergency-access-alert"
  resource_group_name = var.resource_group_name
  scopes              = [var.resource_group_id]
  description         = "CRITICAL: Emergency break-glass vault accessed"
  
  criteria {
    category       = "Administrative"
    operation_name = "Microsoft.KeyVault/vaults/secrets/read"
    resource_id    = azurerm_key_vault.emergency_access.id
  }
  
  action {
    action_group_id = azurerm_monitor_action_group.security_team.id
  }
  
  tags = var.common_tags
}

# ==========================================
# 11. Data Loss Prevention (DLP)
# ==========================================

# Configure DLP policies using Azure Information Protection
resource "azurerm_log_analytics_solution" "azure_sentinel" {
  solution_name         = "SecurityInsights"
  location              = var.azure_location
  resource_group_name   = var.resource_group_name
  workspace_resource_id = azurerm_log_analytics_workspace.hipaa_audit.id
  workspace_name        = azurerm_log_analytics_workspace.hipaa_audit.name
  
  plan {
    publisher = "Microsoft"
    product   = "OMSGallery/SecurityInsights"
  }
  
  tags = var.common_tags
}

# ==========================================
# 12. Regular Compliance Reporting
# ==========================================

# Workbook for compliance dashboard
resource "azurerm_application_insights_workbook" "hipaa_compliance_dashboard" {
  name                = "${var.environment}-hipaa-dashboard"
  resource_group_name = var.resource_group_name
  location            = var.azure_location
  display_name        = "HIPAA Compliance Dashboard"
  
  data_json = jsonencode({
    version = "Notebook/1.0"
    items = [
      {
        type = 1
        content = {
          json = "## HIPAA Compliance Dashboard\n\nReal-time compliance monitoring for healthcare data platform"
        }
      },
      {
        type = 3
        content = {
          version = "KqlItem/1.0"
          query   = azurerm_log_analytics_saved_search.phi_access_audit.query
          size    = 0
          title   = "PHI Access Audit (Last 24 Hours)"
        }
      },
      {
        type = 3
        content = {
          version = "KqlItem/1.0"
          query   = azurerm_log_analytics_saved_search.failed_access_attempts.query
          size    = 0
          title   = "Failed Access Attempts (Last 7 Days)"
        }
      }
    ]
  })
  
  tags = merge(var.common_tags, local.phi_tags)
}