# Configure the Azure provider
provider "azurerm" { 
    # The "feature" block is required for AzureRM provider 2.x. 
    # If you're using version 1.x, the "features" block is not allowed.
    version = "~>2.0"
    features {}
}

data "azurerm_key_vault" "mykv" {
  name                = "AppDeploymentKV"
  resource_group_name = "Deploy"
}

data "azurerm_key_vault_secret" "kvrgname" {
  name         = "dev-eshoprgname"
  key_vault_id = data.azurerm_key_vault.mykv.id
}
data "azurerm_key_vault_secret" "kvlocation" {
  name         = "dev-ageswrglocation"
  key_vault_id = data.azurerm_key_vault.mykv.id
}

data "azurerm_key_vault_secret" "kvasp" {
  name         = "dev-ageswaspname"
  key_vault_id = data.azurerm_key_vault.mykv.id
}

data "azurerm_key_vault_secret" "kvtier" {
  name         = "dev-ageswasptier"
  key_vault_id = data.azurerm_key_vault.mykv.id
}

data "azurerm_key_vault_secret" "kvsize" {
  name         = "dev-ageswaspsize"
  key_vault_id = data.azurerm_key_vault.mykv.id
}

data "azurerm_key_vault_secret" "kvwebname" {
  name         = "dev-ageswapservicename"
  key_vault_id = data.azurerm_key_vault.mykv.id
}


data "azurerm_key_vault_secret" "kvsqlserver" {
  name         = "dev-ageswsqlservername"
  key_vault_id = data.azurerm_key_vault.mykv.id
}
data "azurerm_key_vault_secret" "kvsqlver" {
  name         = "dev-ageswsqlversion"
  key_vault_id = data.azurerm_key_vault.mykv.id
}
data "azurerm_key_vault_secret" "kvlogin" {
  name         = "dev-ageswsqladministrator-login"
  key_vault_id = data.azurerm_key_vault.mykv.id
}
data "azurerm_key_vault_secret" "kvpass" {
  name         = "dev-ageswsqladministrator-login-password"
  key_vault_id = data.azurerm_key_vault.mykv.id
}
data "azurerm_key_vault_secret" "kvdb" {
  name         = "dev-ageswdbname"
  key_vault_id = data.azurerm_key_vault.mykv.id
}
data "azurerm_key_vault_secret" "kvedition" {
  name         = "dev-ageswdbedition"
  key_vault_id = data.azurerm_key_vault.mykv.id
}
data "azurerm_key_vault_secret" "kvcollation" {
  name         = "dev-ageswdbcollation"
  key_vault_id = data.azurerm_key_vault.mykv.id
}
data "azurerm_key_vault_secret" "kvmode" {
  name         = "dev-ageswdbcreate-mode"
  key_vault_id = data.azurerm_key_vault.mykv.id
}
data "azurerm_key_vault_secret" "kvobj" {
  name         = "dev-ageswdbrequested-service-objective-name"
  key_vault_id = data.azurerm_key_vault.mykv.id
}
data "azurerm_key_vault_secret" "kvrule" {
  name         = "dev-ageswdbsecrulename"
  key_vault_id = data.azurerm_key_vault.mykv.id
}
data "azurerm_key_vault_secret" "kvstartip" {
  name         = "dev-ageswstart-ip-address"
  key_vault_id = data.azurerm_key_vault.mykv.id
}
data "azurerm_key_vault_secret" "kvendip" {
  name         = "dev-ageswend-ip-address"
  key_vault_id = data.azurerm_key_vault.mykv.id
}


resource "azurerm_resource_group" "webshopdemo" {
    name = data.azurerm_key_vault_secret.kvrgname.value
    location =  data.azurerm_key_vault_secret.kvlocation.value
}

resource "azurerm_app_service_plan" "webshopdemo" {
    name                =   data.azurerm_key_vault_secret.dev-ageswaspname.value
    location            = azurerm_resource_group.webshopdemo.location
    resource_group_name = azurerm_resource_group.webshopdemo.name
    sku {
        tier = data.azurerm_key_vault_secret.kvtier.value
        size =  data.azurerm_key_vault_secret.kvsize.value
    }
}

resource "azurerm_app_service" "webshopdemo" {
    name                =  data.azurerm_key_vault_secret.kvwebname.value
    location            = azurerm_resource_group.webshopdemo.location
    resource_group_name = azurerm_resource_group.webshopdemo.name
    app_service_plan_id = azurerm_app_service_plan.webshopdemo.id
}


resource "azurerm_sql_server" "webshopdemo" {
  name                         =  data.azurerm_key_vault_secret.kvsqlserver.value
  resource_group_name          = azurerm_resource_group.webshopdemo.name
  location                     = azurerm_resource_group.webshopdemo.location
  version                      =  data.azurerm_key_vault_secret.kvsqlver.value
  administrator_login          =  data.azurerm_key_vault_secret.kvlogin.value
  administrator_login_password =  data.azurerm_key_vault_secret.kvpass.value
}

resource "azurerm_sql_database" "webshopdemo" {
  name                             = data.azurerm_key_vault_secret.kvdb.value
  resource_group_name              = azurerm_resource_group.webshopdemo.name
  location                         = azurerm_resource_group.webshopdemo.location
  server_name                      = azurerm_sql_server.webshopdemo.name
  edition                          =  data.azurerm_key_vault_secret.kvedition.value
  collation                        =  data.azurerm_key_vault_secret.kvcollation.value
  create_mode                      =  data.azurerm_key_vault_secret.kvmode.value
  requested_service_objective_name =  data.azurerm_key_vault_secret.kvobj.value
}

# Enables the "Allow Access to Azure services" box as described in the API docs
# https://docs.microsoft.com/en-us/rest/api/sql/firewallrules/createorupdate
resource "azurerm_sql_firewall_rule" "webshopdemo" {
  name                = data.azurerm_key_vault_secret.kvrule.value
  resource_group_name = azurerm_resource_group.webshopdemo.name
  server_name         = azurerm_sql_server.webshopdemo.name
  start_ip_address    =  data.azurerm_key_vault_secret.kvstartip.value
  end_ip_address      =  data.azurerm_key_vault_secret.kvendip.value
}

