module "aks_resource_group" {
  source = "../../modules/bits/resource_group"

  name     = module.conventions.names.aks.azurerm_resource_group
  location = var.location
}



resource "azurerm_kubernetes_cluster" "aks_cluster" {
  name                = module.conventions.names.aks.kubernetes_cluster
  location            = var.location
  resource_group_name = module.aks_resource_group.name
  dns_prefix          = "dev-aks"

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
    service_cidr       = "10.10.4.0/22"
    dns_service_ip     = "10.10.4.10"
    docker_bridge_cidr = "172.17.0.0/16"
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

}

resource "azurerm_windows_virtual_machine" "vm" {
  name                = "myVM"
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  size                = "Standard_DS1_v2"
  admin_username      = "adminuser"
  admin_password      = "P@ssw0rd123!"
  network_interface_ids = [
    azurerm_network_interface.nic.id,
  ]

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "MicrosoftWindowsServer"
    offer     = "WindowsServer"
    sku       = "2019-Datacenter"
    version   = "latest"
  }
}



