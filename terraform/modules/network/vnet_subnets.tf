# https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/virtual_network
resource "azurerm_virtual_network" "virtual_network" {
  name                = module.conventions.names.network.virtual_network
  location            = var.location
  resource_group_name = module.network_resource_group.name

  address_space = ["172.31.144.0/22"]

  #dns_servers = compact(split(";", var.dns_servers))

}

locals {
  # https://www.terraform.io/language/functions/cidrsubnets
  subnets = cidrsubnets(azurerm_virtual_network.virtual_network.address_space[0], 1, 3, 3, 3, 3)
}


# https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/subnet
resource "azurerm_subnet" "public_subnet" {
  name                 = module.conventions.names.network.subnet_public
  resource_group_name  = module.network_resource_group.name
  address_prefixes     = [local.subnets[1]]
  virtual_network_name = azurerm_virtual_network.virtual_network.name
}

resource "azurerm_subnet" "iaas_subnet" {
  name                 = module.conventions.names.network.subnet_iaas
  resource_group_name  = module.network_resource_group.name
  address_prefixes     = [local.subnets[2]]
  virtual_network_name = azurerm_virtual_network.virtual_network.name
}

resource "azurerm_subnet" "paas_subnet" {
  name                 = module.conventions.names.network.subnet_paas
  resource_group_name  = module.network_resource_group.name
  address_prefixes     = [local.subnets[0]] # PaaS subnet requires a /23 space
  virtual_network_name = azurerm_virtual_network.virtual_network.name
}

resource "azurerm_subnet" "backend_subnet" {
  name                 = module.conventions.names.network.subnet_backend
  resource_group_name  = module.network_resource_group.name
  address_prefixes     = [local.subnets[3]]
  virtual_network_name = azurerm_virtual_network.virtual_network.name
}
