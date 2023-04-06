terraform {
  required_version = ">= 1.3"
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.0"
    }
  }
}

provider "azurerm" {
  features {}
}


# Reference to the current subscription.  Used when creating role assignments
data "azurerm_subscription" "current" {}


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


resource "azurerm_container_registry" "default" {
  name                     = data.azurerm_key_vault_secret.acrname.value
  resource_group_name      = data.azurerm_key_vault_secret.kvrgname.value
  location                 = data.azurerm_key_vault_secret.kvlocation.value
  sku                      = "Standard"
  admin_enabled            = false
}
resource "azurerm_user_assigned_identity" "default" {
  location            = data.azurerm_key_vault_secret.kvlocation.value
  name                = "askidentityname"
  resource_group_name = data.azurerm_key_vault_secret.kvrgname.value
}

# need to move the following 2 blocks out to the azure cli to perform post processing
# user defined managed account as network contrib to rg
#resource "azurerm_role_assignment" "default" {
#  scope                =  data.azurerm_key_vault_secret.kvrgname.id
#  role_definition_name = "Network Contributor"
#  principal_id         = azurerm_user_assigned_identity.aks.principal_id
#}
#rights to pull from registry for udma
#resource "azurerm_role_assignment" "default" {
#  scope                = azurerm_container_registry.default.id
#  role_definition_name = "AcrPull"
#  principal_id         = azurerm_user_assigned_identity.default.principal_id
#}
resource "azurerm_kubernetes_cluster" "default" {
  name                              = data.azurerm_key_vault_secret.aksname.value
  location                          = data.azurerm_key_vault_secret.kvlocation.value
  resource_group_name               = data.azurerm_key_vault_secret.kvrgname.value
  dns_prefix                        = data.azurerm_key_vault_secret.aksname.value


  #azure_active_directory {
  #  managed = true
  #  admin_group_object_ids = [
  #    "bb848a2d-602f-474a-81b7-9b8893ca834c"
  #  ]
  #}

  default_node_pool {
    name            = "default"
    vm_size         = data.azurerm_key_vault_secret.aksvmsize.value
    node_count      = 3
    os_disk_size_gb = 30
  }


  #user_assigned_identity_id = azurerm_user_assigned_identity.default.id
  identity {
    type         = "UserAssigned"
    identity_ids = [azurerm_user_assigned_identity.default.id]
  }

  #depends_on                        = [azurerm_role_assignment.aks_network, azurerm_role_assignment.aks_acr]
}

resource "azurerm_role_assignment" "default" {
  scope                = data.azurerm_key_vault_secret.aksname.id
  role_definition_name = "Monitoring Metrics Publisher"
  principal_id         = azurerm_kubernetes_cluster.default.identity[0].principal_id
}
#resource "azurerm_role_assignment" "aks_subnet" {
#  scope                = var.vnet_subnet_id
#  role_definition_name = "Network Contributor"
#  principal_id         = azurerm_kubernetes_cluster.default.identity[0].principal_id
#}
resource "azurerm_role_assignment" "roleass" {
  scope                = data.azurerm_key_vault_secret.acrname.id
  role_definition_name = "AcrPull"
  principal_id         = azurerm_kubernetes_cluster.default.kubelet_identity[0].object_id
}
