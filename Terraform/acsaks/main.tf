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


#locals {
#  rgname = data.azurerm_key_vault_secret.kvrgname.value
#  acrname = data.azurerm_key_vault_secret.acrname.value
#  environment = "dev"
#  rglocation = data.azurerm_key_vault_secret.kvlocation.value
#  aksnode_count = 3
#  aksnode_type = data.azurerm_key_vault_secret.aksvmsize.value
#  aksdns_prefix = data.azurerm_key_vault_secret.aksname.value
#}


#// Node type information

#variable "node_count" {
#  type        = number
#  description = "The number of K8S nodes to provision."
#  default     = 3
#}

#variable "node_type" {
#  type        = string
#  description = "The size of each node."
#  default     = data.azurerm_key_vault_secret.aksvmsize.value
#}

#variable "dns_prefix" {
#  type        = string
#  description = "DNS Prefix"
#  default     = data.azurerm_key_vault_secret.aksname.value

#// Naming
#variable "name" {
#  type        = string
#  description = "Location of the azure resource group."
#  default     = data.azurerm_key_vault_secret.kvrgname.value
#}

#variable "acrname" {
#  type        = string
#  description = "name of the ACR"
#  default     = data.azurerm_key_vault_secret.acrname.value
#}


#variable "environment" {
#  type        = string
#  description = "Name of the deployment environment"
#  default     = "dev"
#}

#// Resource information

#variable "location" {
#  type        = string
#  description = "Location of the azure resource group."
#  default     = data.azurerm_key_vault_secret.kvlocation.value
#}

#}
#data "azurerm_resource_group" "default" {
#  name = "${var.project_name}-${var.environment}-rg"
#}

## The main resource group for this deployment
#resource "azurerm_resource_group" "default" {
#  name     = data.azurerm_key_vault_secret.kvrgname.value
#  location = data.azurerm_key_vault_secret.kvlocation.value
#}


resource "azurerm_container_registry" "default" {
  name                     = data.azurerm_key_vault_secret.acrname.value
  resource_group_name      = data.azurerm_key_vault_secret.kvrgname.value
  location                 = data.azurerm_key_vault_secret.kvlocation.value
  sku                      = "Standard"
  admin_enabled            = false
}
resource "azurerm_user_assigned_identity" "aks" {
  location            = data.azurerm_key_vault_secret.kvlocation.value
  name                = "askidentityname"
  resource_group_name = data.azurerm_key_vault_secret.kvrgname.value
}

resource "azurerm_role_assignment" "aks_network" {
  scope                = data.azurerm_key_vault_secret.kvrgname.id
  role_definition_name = "Network Contributor"
  principal_id         = azurerm_user_assigned_identity.aks.principal_id
}

resource "azurerm_role_assignment" "aks_acr" {
  scope                = azurerm_container_registry.default.id
  role_definition_name = "AcrPull"
  principal_id         = azurerm_user_assigned_identity.aks.principal_id
}
resource "azurerm_kubernetes_cluster" "default" {
  name                              = data.azurerm_key_vault_secret.aksname.value
  location                          = data.azurerm_key_vault_secret.kvlocation.value
  resource_group_name               = data.azurerm_key_vault_secret.kvrgname.value
  dns_prefix                        = data.azurerm_key_vault_secret.aksname.value
  role_based_access_control_enabled = true

  default_node_pool {
    name            = "default"
    vm_size         = data.azurerm_key_vault_secret.aksvmsize.value
    node_count      = 3
    os_disk_size_gb = 30
  }
  identity {
    type         = "UserAssigned"
    identity_ids = [azurerm_user_assigned_identity.aks.id]
  }

  depends_on                        = [azurerm_role_assignment.aks_network, azurerm_role_assignment.aks_acr]
}
