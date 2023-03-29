provider "azurerm" {
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
data "azurerm_key_vault_secret" "acrname" {
  name         = "dev-eshopwebacr"
  key_vault_id = data.azurerm_key_vault.mykv.id
}
data "azurerm_key_vault_secret" "aksname" {
  name         = "dev-aksname"
  key_vault_id = data.azurerm_key_vault.mykv.id
}
data "azurerm_key_vault_secret" "aksvmsize" {
  name         = "dev-aksvmsize"
  key_vault_id = data.azurerm_key_vault.mykv.id
}




resource "azurerm_container_registry" "webshopaks" {
  name                = data.azurerm_key_vault_secret.acrname.value
  resource_group_name = data.azurerm_key_vault_secret.kvrgname.value
  location            = data.azurerm_key_vault_secret.kvlocation.value
  sku                 = "Basic"
}

resource "azurerm_kubernetes_cluster" "webshopaks" {
  name                = data.azurerm_key_vault_secret.aksname.value
  location            = data.azurerm_key_vault_secret.kvlocation.value
  resource_group_name = data.azurerm_key_vault_secret.kvrgname.value
  dns_prefix          = data.azurerm_key_vault_secret.aksname.value

  default_node_pool {
    name       = "default"
    node_count = 1
    vm_size    = data.azurerm_key_vault_secret.aksvmsize.value
  }

  identity {
    type = "SystemAssigned"
  }
}