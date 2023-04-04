terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = ">= 2.62.0"
    }
  }
}




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
    type = "UserAssigned"
    identity_ids = [
      "/subscriptions/7085574e-de5f-47b0-8725-8f4abb74c8de/resourceGroups/Deploy/providers/Microsoft.ManagedIdentity/userAssignedIdentities/akskvmanagedid"
    ]
  }


}

#locals {
#  kv_csi_settings = {
#    linux = {
#      enabled = true
#      resources = {
#        requests = {
#          cpu    = "100m"
#          memory = "100Mi"
#        }
#        limits = {
#          cpu    = "100m"
#          memory = "100Mi"
#        }
#      }
#    }
#    secrets-store-csi-driver = {
#      install = true
#      linux = {
#        enabled = true
#      }
#      logLevel = {
#        debug = true
#      }
#    }
#  }
#}


#resource "helm_release" "kv_csi" {
#  name         = "csi-secrets-store-provider-azure"
#  chart        = "csi-secrets-store-provider-azure"
#  version      = "0.0.8"
#  repository   = "https://raw.githubusercontent.com/Azure/secrets-store-csi-driver-provider-azure/master/charts"
#  namespace    = "kube-system"
#  max_history  = 4
#  atomic       = true
#  reuse_values = false
#  timeout      = 1800
#  values       = [yamlencode(local.kv_csi_settings)]
#  depends_on = [
#    azurerm_kubernetes_cluster.webshopaks
#  ]

#}


#  resource "helm_release" "csi_secrets_store_provider_azure" {
#  name       = "csi-secrets-store-provider-azure"
#  repository = "https://raw.githubusercontent.com/Azure/secrets-store-csi-driver-provider-azure/master/charts"
#  chart      = "csi-secrets-store-provider-azure"

#      set {
#        name  = "secrets-store-csi-driver.enabled"
#        value = true
#      }
#  }


#resource "helm_release" "csi_secrets_store_provider_azure" {
#  name       = "csi-secrets-store-provider-azure"
#  repository = "https://raw.githubusercontent.com/Azure/secrets-store-csi-driver-provider-azure/master/charts"
#  chart      = "csi-secrets-store-provider-azure"

#  set {
#    name  = "secrets-store-csi-driver.enabled"
#    value = true
#  }

#  depends_on = [azurerm_kubernetes_cluster.webshopaks]
#}