# Configure the Azure provider
provider "azurerm" { 
    # The "feature" block is required for AzureRM provider 2.x. 
    # If you're using version 1.x, the "features" block is not allowed.
    version = "~>2.0"
    features {}
}

data "azurerm_key_vault" "AppDeploymentKV" {
  name                = "AppDeploymentKV"
  resource_group_name = "Deploy"
}

data "azurerm_key_vault_secret" "webshopdemo" {
  name         = "rgname"
  key_vault_id = data.azurerm_key_vault.AppDeploymentKV.id
}
data "azurerm_key_vault_secret" "webshopdemo" {
  name         = "dev-ageswrglocation"
  key_vault_id = data.azurerm_key_vault.dev-ageswrglocation.id
}

data "azurerm_key_vault_secret" "webshopdemo" {
  name         = "dev-ageswaspname"
  key_vault_id = data.azurerm_key_vault.dev-ageswaspname.id
}

data "azurerm_key_vault_secret" "webshopdemo" {
  name         = "dev-ageswasptier"
  key_vault_id = data.azurerm_key_vault.dev-ageswasptier.id
}

data "azurerm_key_vault_secret" "webshopdemo" {
  name         = "dev-dev-ageswasptier"
  key_vault_id = data.azurerm_key_vault.dev-dev-ageswasptier.id
}

data "azurerm_key_vault_secret" "webshopdemo" {
  name         = "dev-ageswapservicename"
  key_vault_id = data.azurerm_key_vault.dev-ageswapservicename.id
}
data "azurerm_key_vault_secret" "webshopdemo" {
  name         = "dev-ageswsqlservername"
  key_vault_id = data.azurerm_key_vault.dev-ageswsqlservername.id
}
data "azurerm_key_vault_secret" "webshopdemo" {
  name         = "dev-ageswsqlversion"
  key_vault_id = data.azurerm_key_vault.dev-ageswsqlversion.id
}
data "azurerm_key_vault_secret" "webshopdemo" {
  name         = "dev-ageswsqladministrator-login"
  key_vault_id = data.azurerm_key_vault.dev-ageswsqladministrator-login.id
}
data "azurerm_key_vault_secret" "webshopdemo" {
  name         = "dev-ageswsqladministrator-login-password"
  key_vault_id = data.azurerm_key_vault.dev-ageswsqladministrator-login-password.id
}
data "azurerm_key_vault_secret" "webshopdemo" {
  name         = "dev-ageswdbname"
  key_vault_id = data.azurerm_key_vault.dev-ageswdbname.id
}
data "azurerm_key_vault_secret" "webshopdemo" {
  name         = "dev-ageswdbedition"
  key_vault_id = data.azurerm_key_vault.dev-ageswdbedition.id
}
data "azurerm_key_vault_secret" "webshopdemo" {
  name         = "dev-ageswdbcollation"
  key_vault_id = data.azurerm_key_vault.dev-ageswdbcollation.id
}
data "azurerm_key_vault_secret" "webshopdemo" {
  name         = "dev-ageswdbcreate-mode"
  key_vault_id = data.azurerm_key_vault.dev-ageswdbcreate-mode.id
}
data "azurerm_key_vault_secret" "webshopdemo" {
  name         = "dev-ageswdbrequested_service_objective_name"
  key_vault_id = data.azurerm_key_vault.dev-ageswdbrequested_service_objective_name.id
}
data "azurerm_key_vault_secret" "webshopdemo" {
  name         = "dev-ageswdbsecrulename"
  key_vault_id = data.azurerm_key_vault.dev-ageswdbsecrulename.id
}
data "azurerm_key_vault_secret" "webshopdemo" {
  name         = "dev-ageswstart-ip-address"
  key_vault_id = data.azurerm_key_vault.dev-ageswstart-ip-address.id
}
data "azurerm_key_vault_secret" "webshopdemo" {
  name         = "dev-ageswend-ip-address"
  key_vault_id = data.azurerm_key_vault.dev-ageswend-ip-address.id
}



resource "azurerm_resource_group" "webshopdemo" {
    name = data.azurerm_key_vault_secret.rgname.value
    location =  data.azurerm_key_vault_secret.dev-ageswrglocation.value
}

resource "azurerm_app_service_plan" "webshopdemo" {
    name                = data.azurerm_key_vault_secret.dev-ageswaspname.value
    location            = azurerm_resource_group.webshopdemo.location
    resource_group_name = azurerm_resource_group.webshopdemo.name
    sku {
        tier = data.azurerm_key_vault_secret.dev-ageswasptier.value
        size =  data.azurerm_key_vault_secret.dev-ageswaspsize.value
    }
}

resource "azurerm_app_service" "webshopdemo" {
    name                =  data.azurerm_key_vault_secret.dev-ageswapservicename.value
    location            = azurerm_resource_group.webshopdemo.location
    resource_group_name = azurerm_resource_group.webshopdemo.name
    app_service_plan_id = azurerm_app_service_plan.webshopdemo.id
}


resource "azurerm_sql_server" "webshopdemo" {
  name                         =  data.azurerm_key_vault_secret.dev-ageswsqlservername.value
  resource_group_name          = azurerm_resource_group.webshopdemo.name
  location                     = azurerm_resource_group.webshopdemo.location
  version                      =  data.azurerm_key_vault_secret.dev-ageswsqlversion.value
  administrator_login          =  data.azurerm_key_vault_secret.dev-ageswsqladministrator-login.value
  administrator_login_password =  data.azurerm_key_vault_secret.dev-ageswsqladministrator-login-password.value
}

resource "azurerm_sql_database" "webshopdemo" {
  name                             = data.azurerm_key_vault_secret.dev-ageswdbname.value
  resource_group_name              = azurerm_resource_group.webshopdemo.name
  location                         = azurerm_resource_group.webshopdemo.location
  server_name                      = azurerm_sql_server.webshopdemo.name
  edition                          = data.azurerm_key_vault_secret.dev-ageswdbedition.value
  collation                        =  data.azurerm_key_vault_secret.dev-ageswdbcollation.value
  create_mode                      =  data.azurerm_key_vault_secret.dev-ageswdbcreate-mode.value
  requested_service_objective_name =  data.azurerm_key_vault_secret.dev-ageswdbrequested_service_objective_name.value
}

# Enables the "Allow Access to Azure services" box as described in the API docs
# https://docs.microsoft.com/en-us/rest/api/sql/firewallrules/createorupdate
resource "azurerm_sql_firewall_rule" "webshopdemo" {
  name                = data.azurerm_key_vault_secret.dev-ageswdbsecrulename.value
  resource_group_name = azurerm_resource_group.webshopdemo.name
  server_name         = azurerm_sql_server.webshopdemo.name
  start_ip_address    =  data.azurerm_key_vault_secret.dev-ageswstart-ip-address.value
  end_ip_address      =  data.azurerm_key_vault_secret.dev-ageswend-ip-address.value
}

