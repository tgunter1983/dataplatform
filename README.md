# Healthcare Data Platform - Terraform Infrastructure

Production-ready Terraform modules for deploying a healthcare data platform on Azure with multi-cloud support.

## What's Inside

This setup deploys:

- **Data Lake Storage** - Bronze/Silver/Gold architecture for data organization
- **Azure Data Factory** - ETL/ELT orchestration
- **Azure Databricks** - Analytics and machine learning workspace
- **Security** - Key Vault, private endpoints, managed identities
- **Monitoring** - Centralized logging with Log Analytics
- **Backup** - Automated disaster recovery

## Architecture

```
Healthcare Platform
│
├── Data Factory ──────> Data Lake (Bronze/Silver/Gold)
│   (Orchestration)            │
│                              │
├── Databricks ────────────────┤
│   (Analytics)                │
│                              │
└── Virtual Network ───────────┘
    ├── Public Subnet
    ├── Private Subnet
    └── Private Endpoints Subnet

Supporting Services:
├── Key Vault (Secrets)
├── Log Analytics (Monitoring)
└── Recovery Services Vault (Backup)
```

## Key Features

**Security First**
- Private endpoints for data lake access
- Network security groups with deny-by-default
- Managed identities (no passwords)
- RBAC assignments
- 90-day soft delete protection

**Data Management**
- Medallion architecture (Bronze → Silver → Gold)
- 30-day blob versioning
- Zone-redundant storage
- Hierarchical namespace for big data

**Monitoring**
- Centralized logging
- 90-day log retention
- Diagnostic settings on all resources

## Prerequisites

**Required:**
- Terraform 1.0+
- Azure CLI 2.0+
- Active Azure subscription with Contributor permissions

**Optional:**
- AWS CLI (for AWS integration)
- Google Cloud SDK (for GCP integration)

## Quick Start

### 1. Set up your Azure account

```bash
az login
az account set --subscription "Your-Subscription-Name"
az account show
```

### 2. Create project structure

```bash
mkdir healthcare-platform && cd healthcare-platform
mkdir -p modules/{resource-group,networking,data-lake,data-factory,databricks,security,monitoring,backup}
```

### 3. Configure your variables

Copy `terraform.tfvars.example` to `terraform.tfvars` and update:

```hcl
environment     = "dev"
azure_location  = "eastus"

common_tags = {
  Environment = "Development"
  Project     = "Healthcare Platform"
  Owner       = "DataEngineering"
}
```

### 4. Deploy

```bash
terraform init
terraform validate
terraform plan -out=tfplan
terraform apply tfplan
```

### 5. Get your endpoints

```bash
terraform output databricks_workspace_url
terraform output data_lake_endpoint
terraform output key_vault_uri
```

## Modules

Each module handles a specific part of the infrastructure:

| Module | What It Does | Depends On |
|--------|-------------|------------|
| resource-group | Creates the base resource group | - |
| networking | Sets up VNet, subnets, NSG | resource-group |
| data-lake | Storage account with Bronze/Silver/Gold | resource-group, networking |
| data-factory | Orchestration and ETL | resource-group, data-lake |
| databricks | Analytics workspace | resource-group, networking, data-lake |
| security | Key Vault for secrets | resource-group |
| monitoring | Log Analytics workspace | resource-group |
| backup | Recovery Services vault | resource-group |

### Module Examples

**Override defaults:**

```hcl
module "data_lake" {
  source = "./modules/data-lake"
  
  # Standard config
  environment           = var.environment
  resource_group_name   = module.resource_group.name
  azure_location        = var.azure_location
  
  # Custom settings
  account_replication_type = "GRS"  # Instead of default ZRS
  retention_days           = 60     # Instead of default 30
}
```

**Deploy only specific modules:**

```bash
terraform apply -target=module.networking -target=module.data_lake
```

## Configuration

### Multiple Environments

Create environment-specific config files:

**dev.tfvars:**
```hcl
environment    = "dev"
azure_location = "eastus"
```

**prod.tfvars:**
```hcl
environment    = "prod"
azure_location = "eastus2"
```

Deploy with: `terraform apply -var-file="prod.tfvars"`

### Remote State

For team collaboration, use remote state:

```hcl
terraform {
  backend "azurerm" {
    resource_group_name  = "terraform-state-rg"
    storage_account_name = "tfstate12345"
    container_name       = "tfstate"
    key                  = "healthcare-platform.tfstate"
  }
}
```

### Terraform Workspaces

Manage multiple environments:

```bash
terraform workspace new dev
terraform workspace new prod
terraform workspace select prod
terraform apply
```

## Security Notes

**Don't commit secrets:**

Add to `.gitignore`:
```
*.tfvars
!terraform.tfvars.example
```

**Use Key Vault for sensitive values:**

```bash
export TF_VAR_admin_password=$(az keyvault secret show \
  --name admin-password \
  --vault-name my-keyvault \
  --query value -o tsv)
```

**Security checklist:**
- Enable Azure Security Center
- Configure Key Vault firewall rules
- Set up diagnostic settings for all resources
- Regular security assessments
- Verify backup encryption

## Monitoring

### Sample Log Analytics Queries

**Failed Data Factory activities (last 24 hours):**
```kusto
ADFActivityRun
| where TimeGenerated > ago(24h)
| where Status == "Failed"
| project TimeGenerated, ActivityName, Status, Error
```

**Storage account access:**
```kusto
StorageBlobLogs
| where TimeGenerated > ago(1h)
| project TimeGenerated, AccountName, OperationName, StatusCode
```

### Set up alerts

```bash
az monitor metrics alert create \
  --name "DataFactoryFailures" \
  --resource-group "prod-healthcare-platform-rg" \
  --scopes $(terraform output -raw data_factory_id) \
  --condition "count ActivityFailedRuns > 5" \
  --window-size 5m
```

## Backup & Recovery

**Automated backups:**
- Data Lake: 30-day soft delete + versioning
- Key Vault: 90-day soft delete + purge protection
- VMs: Daily/weekly/monthly/yearly retention (if enabled)

**Recovery targets:**
- RTO (Recovery Time): < 4 hours
- RPO (Recovery Point): < 1 hour

**Restore a deleted blob:**

```bash
az storage blob restore \
  --account-name devhealthcaredl \
  --container-name bronze \
  --name data/file.parquet \
  --restore-to-latest
```

**Recover a deleted Key Vault:**

```bash
az keyvault list-deleted
az keyvault recover --name dev-hc-kv --resource-group dev-healthcare-platform-rg
```

## Cost Estimates

Development environment (monthly):

- Data Lake Storage: $20-50
- Data Factory: $5-20
- Databricks: $100-300 (light usage)
- Key Vault: $3-5
- Log Analytics: $2-10 (1GB/day)
- Recovery Services: $5-10
- Virtual Network: $0-5

**Total: ~$135-400/month** (varies by usage and region)

**Save money:**
- Use Standard Databricks SKU for dev/test
- Implement lifecycle policies to archive old data
- Use Azure Reservations for production workloads
- Enable auto-shutdown for non-production resources

## Troubleshooting

### Storage account name already taken

Storage account names must be globally unique. Add a random suffix:

```hcl
resource "azurerm_storage_account" "data_lake" {
  name = "${var.environment}${random_string.suffix.result}healthcaredl"
  # ...
}

resource "random_string" "suffix" {
  length  = 4
  special = false
  upper   = false
}
```

### Key Vault access denied

Add yourself to the access policy:

```bash
az keyvault set-policy \
  --name dev-hc-kv \
  --object-id $(az ad signed-in-user show --query objectId -o tsv) \
  --secret-permissions get list set
```

### Databricks deployment fails

Check subnet delegation:

```bash
az network vnet subnet show \
  --resource-group dev-healthcare-platform-rg \
  --vnet-name dev-healthcare-vnet \
  --name databricks-public-subnet \
  --query "delegations"
```

### Debug mode

Enable detailed logging:

```bash
export TF_LOG=DEBUG
export TF_LOG_PATH=./terraform-debug.log
terraform apply
```

## Contributing

Contributions welcome! Here's how:

1. Fork the repo
2. Create a feature branch: `git checkout -b feature/my-feature`
3. Make your changes and test:
   ```bash
   terraform fmt -recursive
   terraform validate
   terraform plan
   ```
4. Commit: `git commit -m "feat: add new feature"`
5. Push and open a PR

**Before submitting:**
- Run `terraform fmt -recursive -check`
- Run `terraform validate`
- Test in a dev environment
- Update documentation

## License

MIT License - see LICENSE file for details.

## Need Help?

- **Issues:** Create an issue on GitHub
- **Documentation:** 
  - [Terraform Azure Provider](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs)
  - [Azure Architecture Center](https://docs.microsoft.com/azure/architecture/)
  - [Databricks Docs](https://docs.databricks.com/)
- **Email:** healthcare-platform@example.com

## What's Next

We're working on:
- Azure Synapse Analytics module
- Azure Purview for data governance
- Multi-region deployment
- Automated testing with Terratest
- CI/CD pipeline examples