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




// Naming
variable "name" {
  type        = string
  description = "Location of the azure resource group."
  default     = data.azurerm_key_vault_secret.kvrgname.value
}

variable "acrname" {
  type        = string
  description = "name of the ACR"
  default     = data.azurerm_key_vault_secret.acrname.value
}


variable "environment" {
  type        = string
  description = "Name of the deployment environment"
  default     = "dev"
}

// Resource information

variable "location" {
  type        = string
  description = "Location of the azure resource group."
  default     = data.azurerm_key_vault_secret.kvlocation.value
}

// Node type information

variable "node_count" {
  type        = number
  description = "The number of K8S nodes to provision."
  default     = 3
}

variable "node_type" {
  type        = string
  description = "The size of each node."
  default     = data.azurerm_key_vault_secret.aksvmsize.value
}

variable "dns_prefix" {
  type        = string
  description = "DNS Prefix"
  default     = data.azurerm_key_vault_secret.aksname.value
}


# The main resource group for this deployment
resource "azurerm_resource_group" "default" {
  name     = var.name
  location = var.location
}
