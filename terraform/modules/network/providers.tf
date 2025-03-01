terraform {
  required_version = ">= 1.0"

  backend "azurerm" {
    storage_account_name = "mvp30backendsa"
    container_name       = "terraform-states"
    key                  = "${var.environment}-${var.application_instance}/network.tfstate"
  }

  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = ">= 3.0.0"
    }
  }

}

provider "azurerm" {
  features {}
  subscription_id = "adff878e-2322-47a1-bd5b-5bc91eb70463"
}