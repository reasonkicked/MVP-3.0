module "aks_resource_group" {
  source = "../../modules/bits/resource_group"

  name     = module.conventions.names.aks.azurerm_resource_group
  location = var.location
}

resource "azurerm_kubernetes_cluster" "aks_cluster" {
  name                = module.conventions.names.aks.kubernetes_cluster
  location            = var.location
  resource_group_name = module.aks_resource_group.name
  dns_prefix          = "exampleaks1"

  default_node_pool {
    name           = "default"
    node_count     = 1
    vm_size        = "Standard_D2_v2"
    vnet_subnet_id = azurerm_subnet.public_subnet.id
  }

  identity {
    type = "SystemAssigned"
  }

  network_profile {
    network_plugin     = "azure"
    service_cidr       = local.subnets[2]
    dns_service_ip     = cidrhost(local.subnets[2], 10)
    docker_bridge_cidr = "172.17.0.1/16"
    outbound_type      = "loadBalancer"
  }

  tags = {
    Environment = "Development"
  }
}


