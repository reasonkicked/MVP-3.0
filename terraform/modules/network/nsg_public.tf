locals {
  public_nsg_rules = {

    AllowSshInBound = {
      name                       = "AllowSshInBound"
      priority                   = 100
      direction                  = "Inbound"
      access                     = "Allow"
      protocol                   = "Tcp"
      source_port_range          = "*"
      destination_port_range     = 22
      source_address_prefix      = var.tooling_vnet_ip_range
      destination_address_prefix = "VirtualNetwork"
    }

    AllowRdpInBound = {
      name                       = "AllowRdpInBound"
      priority                   = 200
      direction                  = "Inbound"
      access                     = "Allow"
      protocol                   = "Tcp"
      source_port_range          = "*"
      destination_port_range     = 3389
      source_address_prefix      = var.tooling_vnet_ip_range
      destination_address_prefix = "VirtualNetwork"
    }

    AllowHttpsInBound = {
      name                       = "AllowHttpsInBound"
      priority                   = 300
      direction                  = "Inbound"
      access                     = "Allow"
      protocol                   = "Tcp"
      source_port_range          = "*"
      destination_port_range     = 443
      source_address_prefix      = var.tooling_vnet_ip_range
      destination_address_prefix = "VirtualNetwork"
    }

    AllowHttpInBound = {
      name                       = "AllowHttpInBound"
      priority                   = 400
      direction                  = "Inbound"
      access                     = "Allow"
      protocol                   = "Tcp"
      source_port_range          = "*"
      destination_port_range     = 80
      source_address_prefix      = var.tooling_vnet_ip_range
      destination_address_prefix = "VirtualNetwork"
    }

    AllowVnetInBound = {
      name                       = "AllowVnetInBound"
      priority                   = 500
      direction                  = "Inbound"
      access                     = "Allow"
      protocol                   = "*"
      source_port_range          = "*"
      destination_port_range     = "*"
      source_address_prefix      = "VirtualNetwork"
      destination_address_prefix = "VirtualNetwork"
    }

    DenyAllInBound = {
      name                       = "DenyAllInBound"
      priority                   = 4000
      direction                  = "Inbound"
      access                     = "Deny"
      protocol                   = "*"
      source_port_range          = "*"
      destination_port_range     = "*"
      source_address_prefix      = "*"
      destination_address_prefix = "*"
    }

    AllowSshOutBound = {
      name                       = "AllowSshOutBound"
      priority                   = 100
      direction                  = "Outbound"
      access                     = "Allow"
      protocol                   = "Tcp"
      source_port_range          = "*"
      destination_port_range     = 22
      source_address_prefix      = "*"
      destination_address_prefix = "*"
    }

    AllowHttpsOutBound = {
      name                       = "AllowHttpsOutBound"
      priority                   = 200
      direction                  = "Outbound"
      access                     = "Allow"
      protocol                   = "Tcp"
      source_port_range          = "*"
      destination_port_range     = 443
      source_address_prefix      = "*"
      destination_address_prefix = "*"
    }

    AllowHttpOutBound = {
      name                       = "AllowHttpOutBound"
      priority                   = 300
      direction                  = "Outbound"
      access                     = "Allow"
      protocol                   = "Tcp"
      source_port_range          = "*"
      destination_port_range     = 80
      source_address_prefix      = "*"
      destination_address_prefix = "*"
    }

    DenyAllOutBound = {
      name                       = "DenyAllOutBound"
      priority                   = 4000
      direction                  = "Outbound"
      access                     = "Deny"
      protocol                   = "*"
      source_port_range          = "*"
      destination_port_range     = "*"
      source_address_prefix      = "*"
      destination_address_prefix = "*"
    }

  }
}

# Public network security group

resource "azurerm_network_security_group" "public_nsg" {
  name                = "${azurerm_subnet.public_subnet.name}-nsg"
  location            = var.location
  resource_group_name = module.network_resource_group.name
}

# Public network security group rules

resource "azurerm_network_security_rule" "public_nsg_rules" {
  for_each = { for k, v in local.public_nsg_rules : k => v if v.source_address_prefix != "" }

  name                        = each.value.name
  priority                    = each.value.priority
  direction                   = each.value.direction
  access                      = each.value.access
  protocol                    = each.value.protocol
  source_port_range           = each.value.source_port_range
  destination_port_range      = each.value.destination_port_range
  source_address_prefix       = each.value.source_address_prefix
  destination_address_prefix  = each.value.destination_address_prefix
  resource_group_name         = module.network_resource_group.name
  network_security_group_name = azurerm_network_security_group.public_nsg.name
}

# Public network security groups association

resource "azurerm_subnet_network_security_group_association" "public_nsg_association" {
  subnet_id                 = azurerm_subnet.public_subnet.id
  network_security_group_id = azurerm_network_security_group.public_nsg.id
}
