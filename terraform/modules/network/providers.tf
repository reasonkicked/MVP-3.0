terraform {
  required_version = ">= 0.15"

  backend "azurerm" {
    storage_account_name = "mvp30sadev"
    container_name       = "terraform"
    key                  = "terraform.tfstate"
  }
}

provider "azurerm" {
  features {}
}
