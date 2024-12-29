terraform {
  required_version = ">= 0.15"

  backend "azurerm" {
    storage_account_name = "mvp30sadev"
    container_name       = "terraform"
    key                  = "terraform.tfstate"
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