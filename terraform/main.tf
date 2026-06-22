terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 4.0" # Pin provider version to avoid unexpected breaking changes.
    }
  }
}

provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "main" {

  # Use variables so the same code can be deployed to multiple environments.
  name     = "${var.app_name}-${var.environment}-rg"
  location = var.location

  tags = {
    Environment = var.environment
    Application = var.app_name
    ManagedBy   = "Terraform"
  }
}

resource "azurerm_log_analytics_workspace" "main" {
  name                = "${var.app_name}-${var.environment}-law"
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name
  sku                 = "PerGB2018"

  # Retain logs longer to support troubleshooting and audits.
  retention_in_days = 30
}

resource "azurerm_container_registry" "main" {
  name                = "${var.app_name}${var.environment}acr"
  resource_group_name = azurerm_resource_group.main.name
  location            = azurerm_resource_group.main.location

  # REVIEW: Consider Standard SKU if geo-replication or advanced features are required.
  sku = "Basic"

  # Disable admin credentials and prefer managed identities.
  admin_enabled = false
}

resource "azurerm_container_app_environment" "main" {

  # Use app and environment values to keep naming consistent.
  name                       = "${var.app_name}-${var.environment}-cae"
  location                   = azurerm_resource_group.main.location
  resource_group_name        = azurerm_resource_group.main.name
  log_analytics_workspace_id = azurerm_log_analytics_workspace.main.id
}

resource "azurerm_container_app" "api" {

  # Use app and environment values to keep naming consistent.
  name                         = "${var.app_name}-${var.environment}-api"
  container_app_environment_id = azurerm_container_app_environment.main.id
  resource_group_name          = azurerm_resource_group.main.name
  revision_mode                = "Single"

  template {
    container {
      name   = "api"
      image  = "${azurerm_container_registry.main.login_server}/${var.app_name}-api:${var.image_tag}"
      cpu    = 2.0
      memory = "4Gi"

      # Use the deployment environment instead of hardcoding Production.
      env {
        name  = "ASPNETCORE_ENVIRONMENT"
        value = var.environment
      }

      # Removed hardcoded database credentials.
      # These values should come from Key Vault or pipeline secrets.
      env {
        name  = "ConnectionStrings__Database"
        value = "Server=sql-myapp-prod.database.windows.net;Database=myapp;User Id=sqladmin;Password=${var.sql_admin_password};Encrypt=true"
      }

      # Removed hardcoded API key.
      # Store sensitive values outside of source control.
      env {
        name  = "API_KEY"
        value = var.api_key
      }

      # Removed hardcoded Datadog API key.
      # Store sensitive values outside of source control.
      env {
        name  = "DATADOG_API_KEY"
        value = var.datadog_api_key
      }
    }

    # Keep at least one replica running to avoid cold starts.
    min_replicas = 1
    max_replicas = 3
  }

  ingress {
    target_port      = 8080
    transport        = "http"
    external_enabled = true

    traffic_weight {
      percentage      = 100
      latest_revision = true
    }
  }

  # REVIEW: The current configuration relies on ACR admin credentials.
  # Consider using a managed identity and AcrPull role assignment
  # instead of registry usernames and passwords.

  registry {
    server = azurerm_container_registry.main.login_server
  }
}