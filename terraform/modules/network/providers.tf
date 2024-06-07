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

resource "random_password" "password" {
  length            = 16
  special           = true
  override_special  = "!@#$%&*()-_=+[]{}<>:?"
}
variable "db_password" {
  description = "The password for the database"
  type        = string
  sensitive   = true
}

