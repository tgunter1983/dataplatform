.
├── main.tf                      # Root module - orchestrates all modules
├── variables.tf                 # Root variables
├── outputs.tf                   # Root outputs
├── terraform.tfvars            # Environment-specific values
└── modules/
    ├── resource-group/         # Resource Group module
    │   ├── main.tf
    │   ├── variables.tf
    │   └── outputs.tf
    ├── networking/             # Virtual Network and Subnets
    │   ├── main.tf
    │   ├── variables.tf
    │   └── outputs.tf
    ├── data-lake/              # Data Lake Storage Gen2
    │   ├── main.tf
    │   ├── variables.tf
    │   └── outputs.tf
    ├── data-factory/           # Azure Data Factory
    │   ├── main.tf
    │   ├── variables.tf
    │   └── outputs.tf
    ├── databricks/             # Databricks Workspace
    │   ├── main.tf
    │   ├── variables.tf
    │   └── outputs.tf
    ├── security/               # Key Vault
    │   ├── main.tf
    │   ├── variables.tf
    │   └── outputs.tf
    ├── monitoring/             # Log Analytics
    │   ├── main.tf
    │   ├── variables.tf
    │   └── outputs.tf
    └── backup/                 # Recovery Services Vault
        ├── main.tf
        ├── variables.tf
        └── outputs.tf

┌─────────────────────────────────────────────────────────────────┐
│                     Healthcare Platform                         │
├─────────────────────────────────────────────────────────────────┤
│                                                                 │
│  ┌──────────────┐          ┌──────────────┐                     │
│  │ Data Factory │--------->|  Data Lake   |                     |
│  │              │          │ Bronze/Silver│                     │
│  │ Orchestration│          │    /Gold     │                     │
│  └──────────────┘          └──────────────┘                     │
│         │                        │                              │
│         │                        │                              │
│         ▼                        ▼                              │
│  ┌──────────────┐          ┌──────────────┐                     │
│  │  Databricks  │--------->|  Key Vault   |                     |
│  │   Premium    │          │   Secrets    │                     │
│  └──────────────┘          └──────────────┘                     │
│         │                                                       │
│         ▼                                                       │
│  ┌──────────────────────────────────────┐                       │
│  │    Virtual Network (10.0.0.0/16)     │                       │ 
│  │  ┌────────────┐  ┌─────────────┐     │                       │
│  │  │  Public    │  │   Private   │     │                       │
│  │  │  Subnet    │  │   Subnet    │     │                       │
│  │  └────────────┘  └─────────────┘     │                       │
│  │  ┌──────────────────────────────┐    │                       │
│  │  │  Private Endpoints Subnet    │    │                       │
│  │  └──────────────────────────────┘    │                       │ 
│  └──────────────────────────────────────┘                       │
│                                                                 │
│  ┌──────────────┐         ┌──────────────┐                      │
│  │ Log Analytics│         │   Recovery   │                      │
│  │  Monitoring  │         │Services Vault│                      │
│  └──────────────┘         └──────────────┘                      │
│                                                                 │
└─────────────────────────────────────────────────────────────────┘
