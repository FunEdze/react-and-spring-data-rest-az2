
data "azurerm_client_config" "current" {}

data "azurerm_kubernetes_service_versions" "current" {
  location = var.location
  include_preview = false
}

# Resource Group
resource "azurerm_resource_group" "rg" {
  name     = "devops_assignment_rg"
  location = var.location
  tags = {
    Environment = var.environment
    ManagedBy   = "Terraform"
  }
}

# Log Analytics for AKS Monitoring
resource "azurerm_log_analytics_workspace" "aks" {
  name                = "aks-monitoring"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  sku                = "PerGB2018"
  retention_in_days   = 30

  tags = {
    Environment = var.environment
    ManagedBy   = "Terraform"
  }
}

# Azure Container Registry (ACR)
resource "azurerm_container_registry" "acr" {
  name                = "devopsassignmentacr"
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  sku                 = "Basic"
  admin_enabled       = true

  tags = {
    Environment = var.environment
    ManagedBy   = "Terraform"
  }
}

# Azure Kubernetes Service (AKS)
resource "azurerm_kubernetes_cluster" "aks" {
  name                = "devopsAssignmentAKS"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  dns_prefix          = "devopsassignment"
  kubernetes_version  = data.azurerm_kubernetes_service_versions.current.latest_version

  default_node_pool {
    name                = "default"
    node_count          = 1
    vm_size            = "Standard_B2s"
    enable_auto_scaling = false
    min_count          = null
    max_count          = null
  }

  identity {
    type = "SystemAssigned"
  }

  sku_tier = "Free"

  oms_agent {
    log_analytics_workspace_id = azurerm_log_analytics_workspace.aks.id
  }

  tags = {
    Environment = var.environment
    ManagedBy   = "Terraform"
  }
}

# Grant AKS permission to pull images from ACR
resource "azurerm_role_assignment" "aks_acr_pull" {
  scope                = azurerm_container_registry.acr.id
  role_definition_name = "AcrPull"
  principal_id         = azurerm_kubernetes_cluster.aks.identity[0].principal_id
}

# Key Vault
resource "azurerm_key_vault" "kv" {
  name                       = "devopsassignmentkv"
  location                   = azurerm_resource_group.rg.location
  resource_group_name        = azurerm_resource_group.rg.name
  tenant_id                  = data.azurerm_client_config.current.tenant_id
  sku_name                  = "standard"
  soft_delete_retention_days = 7
  purge_protection_enabled   = false
  enable_rbac_authorization = false

  network_acls {
    default_action = "Allow"  # Changed from "Deny"
    bypass         = "AzureServices"
  }

  tags = {
    Environment = var.environment
    ManagedBy   = "Terraform"
  }
}

# Key Vault Access Policy
resource "azurerm_key_vault_access_policy" "service_principal" {
  key_vault_id = azurerm_key_vault.kv.id
  tenant_id    = data.azurerm_client_config.current.tenant_id
  object_id    = data.azurerm_client_config.current.object_id

  secret_permissions = [
    "Get",
    "List",
    "Set",
    "Delete",
    "Recover",
    "Backup",
    "Restore",
    "Purge"
  ]
}

# SQL Server Configuration
resource "azurerm_mssql_server" "sqlserver" {
  name                         = "mazdasqlserver2024"
  resource_group_name          = azurerm_resource_group.rg.name
  location                     = azurerm_resource_group.rg.location
  version                      = "12.0"
  administrator_login          = var.sql_admin_username
  administrator_login_password = var.sql_admin_password
  minimum_tls_version         = "1.2"

  azuread_administrator {
    login_username = "SQL Admin"
    object_id     = data.azurerm_client_config.current.object_id
  }

  tags = {
    Environment = var.environment
    ManagedBy   = "Terraform"
  }
}

# SQL Server Firewall Rules
resource "azurerm_mssql_firewall_rule" "allow_azure_services" {
  name             = "AllowAzureServices"
  server_id        = azurerm_mssql_server.sqlserver.id
  start_ip_address = "0.0.0.0"
  end_ip_address   = "0.0.0.0"
}

# SQL Database Configuration
resource "azurerm_mssql_database" "sqldb" {
  name      = "devopsAssignmentDB"
  server_id = azurerm_mssql_server.sqlserver.id
  sku_name  = "Basic"

  tags = {
    Environment = var.environment
    ManagedBy   = "Terraform"
  }
}

# Store SQL credentials in Key Vault
resource "azurerm_key_vault_secret" "sql_url" {
  name         = "sql-url"
  value        = azurerm_mssql_server.sqlserver.fully_qualified_domain_name
  key_vault_id = azurerm_key_vault.kv.id

  depends_on = [azurerm_key_vault_access_policy.service_principal]
}

resource "azurerm_key_vault_secret" "sql_username" {
  name         = "sql-username"
  value        = var.sql_admin_username
  key_vault_id = azurerm_key_vault.kv.id

  depends_on = [azurerm_key_vault_access_policy.service_principal]
}

resource "azurerm_key_vault_secret" "sql_password" {
  name         = "sql-password"
  value        = var.sql_admin_password
  key_vault_id = azurerm_key_vault.kv.id

  depends_on = [azurerm_key_vault_access_policy.service_principal]
}

# Outputs
output "acr_login_server" {
  value = azurerm_container_registry.acr.login_server
}

output "key_vault_uri" {
  value = azurerm_key_vault.kv.vault_uri
}

output "sql_server_fqdn" {
  value = azurerm_mssql_server.sqlserver.fully_qualified_domain_name
}

output "database_name" {
  value = azurerm_mssql_database.sqldb.name
}

output "aks_cluster_name" {
  value = azurerm_kubernetes_cluster.aks.name
}