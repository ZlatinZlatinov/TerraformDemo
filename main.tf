# We strongly recommend using the required_providers
# To add dynamycally vatiables use this: 
# terraform apply -var="subscription_id=$(az account show --query id -o tsv)"
# terraform apply -var-file="variables.tfvars"

terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "=4.1.0"
    }
  }
  backend "azurerm" {
    resource_group_name  = "TfStorageRG"
    storage_account_name = "zlatintaskboardstrg"
    container_name       = "zlatintbcontainer"
    key                  = "terraform.tfstate"
  }
}

# Configure the Microsoft Azure Provider
provider "azurerm" {
  features {}

  subscription_id = var.subscription_id
}

resource "random_integer" "randint" {
  min = 10000
  max = 99999
}

resource "azurerm_resource_group" "arg" {
  name     = "${var.resource_group_name}${random_integer.randint.result}"
  location = var.resource_group_location
}

resource "azurerm_service_plan" "azserpln" {
  name                = "${var.appservice_plan_name}${random_integer.randint.result}"
  resource_group_name = azurerm_resource_group.arg.name
  location            = azurerm_resource_group.arg.location
  os_type             = "Linux"
  sku_name            = "F1"
}

resource "azurerm_app_service_source_control" "azappsersctrl" {
  app_id                 = azurerm_linux_web_app.azlwebapp.id
  repo_url               = var.github_repo_url
  branch                 = "main"
  use_manual_integration = true
}

resource "azurerm_mssql_server" "azmssqls" {
  name                         = "${var.sql_server_name}${random_integer.randint.result}"
  resource_group_name          = azurerm_resource_group.arg.name
  location                     = azurerm_resource_group.arg.location
  version                      = "12.0"
  administrator_login          = var.sql_admin_login_name
  administrator_login_password = "thisIsKat11"
}

resource "azurerm_mssql_database" "azmssqldb" {
  name           = "${var.sql_database_name}${random_integer.randint.result}"
  server_id      = azurerm_mssql_server.azmssqls.id
  collation      = "SQL_Latin1_General_CP1_CI_AS"
  license_type   = "LicenseIncluded"
  max_size_gb    = 2
  sku_name       = "S0"
  zone_redundant = false
}

resource "azurerm_linux_web_app" "azlwebapp" {
  name                = "${var.appservice_name}${random_integer.randint.result}"
  resource_group_name = azurerm_resource_group.arg.name
  location            = azurerm_service_plan.azserpln.location
  service_plan_id     = azurerm_service_plan.azserpln.id

  site_config {
    application_stack {
      dotnet_version = "6.0"
    }
    always_on = false
  }

  connection_string {
    name  = "DefaultConnection"
    type  = "SQLAzure"
    value = "Data Source=tcp:${azurerm_mssql_server.azmssqls.fully_qualified_domain_name},1433;Initial Catalog=${azurerm_mssql_database.azmssqldb.name};User ID=${azurerm_mssql_server.azmssqls.administrator_login};Password=${azurerm_mssql_server.azmssqls.administrator_login_password};Trusted_Connection=False; MultipleActiveResultSets=True;"
  }
}

resource "azurerm_mssql_firewall_rule" "azmsssqlfirewall" {
  name             = "${var.firewall_rule_name}${random_integer.randint.result}"
  server_id        = azurerm_mssql_server.azmssqls.id
  start_ip_address = "0.0.0.0"
  end_ip_address   = "0.0.0.0"
}