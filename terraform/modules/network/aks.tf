module "aks_resource_group" {
  source = "../../modules/bits/resource_group"

  name     = module.conventions.names.aks.azurerm_resource_group
  location = var.location
}



resource "azurerm_kubernetes_cluster" "aks_cluster" {
  name                = module.conventions.names.aks.kubernetes_cluster
  location            = var.location
  resource_group_name = module.aks_resource_group.name
  dns_prefix          = "exampleaks3"

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
    service_cidr       = "10.10.4.0/22" # A non-overlapping range within the new VNET address space
    dns_service_ip     = "10.10.4.10"   # An IP within the new service_cidr
    docker_bridge_cidr = "172.17.0.0/16" # Default Docker bridge network range
    outbound_type      = "loadBalancer"
  }

  tags = {
    Environment = "Development"
  }
}

resource "azurerm_kubernetes_cluster_node_pool" "node_pool" {
  name                  = module.conventions.names.aks.kubernetes_cluster_node_pool
  kubernetes_cluster_id = azurerm_kubernetes_cluster.aks_cluster.id
  vm_size               = "Standard_DS2_v2"
  node_count            = 2
  vnet_subnet_id        = azurerm_subnet.public_subnet.id # Replace with your desired subnet
  sku_tier              = "Paid"
}



