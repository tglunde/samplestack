provider "azurerm" {
    # The "feature" block is required for AzureRM provider 2.x. 
    # If you are using version 1.x, the "features" block is not allowed.
    version = "~>2.0"
    features {}

    use_msi = true
    client_id = var.client_id
    client_secret = var.client_secret
    subscription_id = "82f8e28a-a01b-4dd3-a860-8c2354534e71"
    tenant_id = "18de8207-6fe3-4572-a0c9-82d1ead85306"
}

terraform {
    backend "azurerm" {}
}

variable "client_id" {}
variable "client_secret" {}

module "aks_cluster" {
    source = "../module/aks"

    agent_count = 1
    client_id = var.client_id
    client_secret = var.client_secret
}