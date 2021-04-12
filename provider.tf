provider "azurerm" {
  features {}
}

provider "azuread" {
}

terraform {
  backend "azurerm" {
  }
}