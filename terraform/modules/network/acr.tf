module "acr_resource_group" {
  source = "../../modules/bits/resource_group"

  name     = module.conventions.names.acr.azurerm_resource_group
  location = var.location
}

resource "azurerm_container_registry" "acr" {
  name                = module.conventions.names.acr.container_registry
  resource_group_name = module.acr_resource_group.name
  location            = var.location
  sku                 = "Premium"
  admin_enabled       = false
  georeplications {
    location                = "East US"
    zone_redundancy_enabled = true
    tags                    = {}
  }
  georeplications {
    location                = "North Europe"
    zone_redundancy_enabled = true
    tags                    = {}
  }
}