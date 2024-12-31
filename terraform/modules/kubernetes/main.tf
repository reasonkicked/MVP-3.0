module "conventions" {
  source = "./../conventions"

  location             = var.location
  environment          = var.environment
  application_name     = var.application_name
  application_instance = var.application_instance
  functions            = var.functions
  resource_instance    = var.resource_instance
}

# module "aks_resource_group" {
#   source = "../../modules/bits/resource_group"
#
#   name     = module.conventions.names.aks.azurerm_resource_group
#   location = var.location
# }
