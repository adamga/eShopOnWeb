# Configure the Azure provider
provider "azurerm" { 
    # The "feature" block is required for AzureRM provider 2.x. 
    # If you're using version 1.x, the "features" block is not allowed.
    version = "~>2.0"
    features {}
}

resource "azurerm_resource_group" "webshopdemo" {
    name = TF_VAR_rgname
    location =  TF_VAR_dev-ageswrglocation
}

resource "azurerm_app_service_plan" "webshopdemo" {
    name                = TF_VAR_dev-ageswaspname
    location            = azurerm_resource_group.webshopdemo.location
    resource_group_name = azurerm_resource_group.webshopdemo.name
    sku {
        tier = TF_VAR_dev-ageswasptier
        size =  TF_VAR_dev-ageswaspsize
    }
}

resource "azurerm_app_service" "webshopdemo" {
    name                =  TF_VAR_dev-ageswapservicename
    location            = azurerm_resource_group.webshopdemo.location
    resource_group_name = azurerm_resource_group.webshopdemo.name
    app_service_plan_id = azurerm_app_service_plan.webshopdemo.id
}


resource "azurerm_sql_server" "webshopdemo" {
  name                         =  TF_VAR_dev-ageswsqlservername
  resource_group_name          = azurerm_resource_group.webshopdemo.name
  location                     = azurerm_resource_group.webshopdemo.location
  version                      =  TF_VAR_dev-ageswsqlversion
  administrator_login          =  TF_VAR_dev-ageswsqladministrator-login
  administrator_login_password =  TF_VAR_dev-ageswsqladministrator-login-password
}

resource "azurerm_sql_database" "webshopdemo" {
  name                             = TF_VAR_dev-ageswdbname
  resource_group_name              = azurerm_resource_group.webshopdemo.name
  location                         = azurerm_resource_group.webshopdemo.location
  server_name                      = azurerm_sql_server.webshopdemo.name
  edition                          = dev-ageswdbedition
  collation                        =  TF_VAR_dev-ageswdbcollation
  create_mode                      =  TF_VAR_dev-ageswdbcreate-mode
  requested_service_objective_name =  TF_VAR_dev-ageswdbrequested_service_objective_name
}

# Enables the "Allow Access to Azure services" box as described in the API docs
# https://docs.microsoft.com/en-us/rest/api/sql/firewallrules/createorupdate
resource "azurerm_sql_firewall_rule" "webshopdemo" {
  name                = TF_VAR_dev-ageswdbsecrulename
  resource_group_name = azurerm_resource_group.webshopdemo.name
  server_name         = azurerm_sql_server.webshopdemo.name
  start_ip_address    =  TF_VAR_dev-ageswstart-ip-address
  end_ip_address      =  TF_VAR_dev-ageswend-ip-address
}

