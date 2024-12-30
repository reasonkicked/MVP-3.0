module "conventions" {
  source = "./../conventions"

  location             = var.location
  environment          = var.environment
  application_name     = var.application_name
  application_instance = var.application_instance
  functions            = var.functions
  resource_instance    = var.resource_instance
}

module "aks_resource_group" {
  source = "../../modules/bits/resource_group"

  name     = module.conventions.names.aks.azurerm_resource_group
  location = var.location
}

data "terraform_remote_state" "network" {
  backend = "azurerm"
  config = {
    resource_group_name  = "ts-rg-01"
    storage_account_name = "mvp30backendsa"
    container_name       = "terraform-states"
    key                  = "${var.environment}-${var.application_instance}/network.tfstate" # Adjust for environment and instance
  }
}

variable "environment" {
  type = string
}

variable "location" {
  type = string
}

variable "application_name" {
  type    = string
  default = "wf"
}

variable "application_instance" {
  type = string
}

variable "functions" {
  type    = set(string)
  default = []
}

variable "resource_instance" {
  type    = number
  default = "01"
}