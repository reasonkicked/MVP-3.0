module "conventions" {
  source = "./../conventions"

  location             = var.location
  environment          = var.environment
  application_name     = var.application_name
  application_instance = var.application_instance
  functions            = var.functions
  resource_instance    = var.resource_instance
}


resource "azurerm_resource_group" "rg" {
  name     = module.conventions.names.network.azurerm_resource_group
  location = var.location
}