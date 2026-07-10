# CST8918 - A09: simple Terraform script used to test the CI pipeline.
# It is never applied - it only needs to pass fmt / validate / tflint.

terraform {
  required_version = ">= 1.5.0"

  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.116"
    }
  }
}

provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "app" {
  name     = "cst8918-a09-rg"
  location = "canadacentral"
}

resource "azurerm_storage_account" "app" {
  name                     = "cst8918a09divyang"
  resource_group_name      = azurerm_resource_group.app.name
  location                 = azurerm_resource_group.app.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
}