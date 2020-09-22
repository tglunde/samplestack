terraform {
  backend "azurerm" {
    resource_group_name   = "tstate"
    storage_account_name  = "tfstatestage1234567890"
    container_name        = "tstate"
    key                   = "terraform.tfstate"
  }
}

provider "azurerm" {
    version = ">=2.28.0"
    features {}
    skip_provider_registration = true
}

resource "azurerm_resource_group" "rg" {
    location = "westeurope"
    name     = "RG-PES-Play-VIAP"
    tags     = {
        "Contact"      = "Ulrich.Frank@vector.com"
        "Department"   = "PES"
        "Environment"  = "Play"
        "Product"      = "VIAP"
        "Project"      = "VIAP"
        "Solutiontype" = "AKS"
    }
}

resource "azurerm_container_registry" "acr" {
    name = "dwhregistry"
    sku = "Standard"
    resource_group_name = azurerm_resource_group.rg.name
    location = azurerm_resource_group.rg.location
}
