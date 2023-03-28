provider "azurerm" {
  features {}
}
data "azurerm_key_vault" "mykv" {
  name                = "AppDeploymentKV"
  resource_group_name = "Deploy"
}

data "azurerm_key_vault_secret" "kvrgname" {
  name         = "rgname"
  key_vault_id = data.azurerm_key_vault.mykv.id
}
data "azurerm_key_vault_secret" "kvlocation" {
  name         = "dev-ageswrglocation"
  key_vault_id = data.azurerm_key_vault.mykv.id
}


resource "azurerm_container_registry" "webshopaks" {
  name                = "agwebshopdemocr"
  resource_group_name = data.azurerm_key_vault_secret.kvrgname.value
  location            = data.azurerm_key_vault_secret.kvlocation.value
  sku                 = "Basic"
}

resource "azurerm_kubernetes_cluster" "webshopaks" {
  name                = "agwebshopcluster"
  location            = data.azurerm_key_vault_secret.kvlocation.value
  resource_group_name = data.azurerm_key_vault_secret.kvrgname.value
  dns_prefix          = "agwebshopcluster"

  default_node_pool {
    name       = "default"
    node_count = 1
    vm_size    = "Standard_D2_v2"
  }

  identity {
    type = "SystemAssigned"
  }
}