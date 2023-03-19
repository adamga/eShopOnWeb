# Configure the Azure provider
provider "azurerm" { 
    # The "feature" block is required for AzureRM provider 2.x. 
    # If you're using version 1.x, the "features" block is not allowed.
    version = "~>2.0"
    features {}
}

resource "azurerm_resource_group" "webshopdemo" {
    name = "ageshopwebdev"
    location = "canadacentral"
}

resource "azurerm_app_service_plan" "webshopdemo" {
    name                = "ageshopwebdevServicePlan"
    location            = azurerm_resource_group.webshopdemo.location
    resource_group_name = azurerm_resource_group.webshopdemo.name
    sku {
        tier = "Standard"
        size = "S1"
    }
}

resource "azurerm_app_service" "webshopdemo" {
    name                = "ageshopwebdevAppService"
    location            = azurerm_resource_group.webshopdemo.location
    resource_group_name = azurerm_resource_group.webshopdemo.name
    app_service_plan_id = azurerm_app_service_plan.webshopdemo.id
}


resource "azurerm_sql_server" "webshopdemo" {
  name                         = "agwebshopdemo-sqlsvr"
  resource_group_name          = azurerm_resource_group.webshopdemo.name
  location                     = azurerm_resource_group.webshopdemo.location
  version                      = "12.0"
  administrator_login          = "webshopdemoadmin"
  administrator_login_password = "P2ssw0rd1234!!"
}

resource "azurerm_sql_database" "webshopdemo" {
  name                             = "agwebshopdemo-db"
  resource_group_name              = azurerm_resource_group.webshopdemo.name
  location                         = azurerm_resource_group.webshopdemo.location
  server_name                      = azurerm_sql_server.webshopdemo.name
  edition                          = "Basic"
  collation                        = "SQL_Latin1_General_CP1_CI_AS"
  create_mode                      = "Default"
  requested_service_objective_name = "Basic"
}

# Enables the "Allow Access to Azure services" box as described in the API docs
# https://docs.microsoft.com/en-us/rest/api/sql/firewallrules/createorupdate
resource "azurerm_sql_firewall_rule" "webshopdemo" {
  name                = "allow-azure-services"
  resource_group_name = azurerm_resource_group.webshopdemo.name
  server_name         = azurerm_sql_server.webshopdemo.name
  start_ip_address    = "0.0.0.0"
  end_ip_address      = "0.0.0.0"
}

