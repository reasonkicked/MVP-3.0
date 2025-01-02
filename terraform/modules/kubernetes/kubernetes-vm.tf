resource "azurerm_public_ip" "public_ip" {
  name                = module.conventions.names.aks.public_ip
  location            = var.location
  resource_group_name = data.terraform_remote_state.network.outputs.resource_group_name
  allocation_method   = "Static"
}

resource "azurerm_network_interface" "nic" {
  name                = module.conventions.names.aks.network_interface
  location            = var.location
  resource_group_name = data.terraform_remote_state.network.outputs.resource_group_name

  ip_configuration {
    name                          = module.conventions.names.aks.network_interface
    subnet_id                     = data.terraform_remote_state.network.outputs.public_subnet_id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.public_ip.id
  }
}

resource "azurerm_linux_virtual_machine" "vm" {
  name                = "ManagementVM"
  resource_group_name = module.aks_resource_group.name
  location            = var.location
  size                = "Standard_B2s"
  admin_username      = "adminuser"

  # Use SSH for authentication
  admin_ssh_key {
    username   = "adminuser"
    public_key = data.azurerm_key_vault_secret.key_vault_id_rsa.value
  }

  network_interface_ids = [
    azurerm_network_interface.nic.id,
  ]

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-server-jammy"
    sku       = "22_04-lts-gen2"
    version   = "latest"
  }

  disable_password_authentication = true
  allow_extension_operations      = true
}


resource "azurerm_dev_test_global_vm_shutdown_schedule" "shutdown_schedule" {
  virtual_machine_id = azurerm_linux_virtual_machine.vm.id
  location           = var.location
  enabled            = true

  # Shutdown at 18:00 Polish time
  daily_recurrence_time = "1800"
  timezone              = "Central European Standard Time" # Polish time zone

  notification_settings {
    enabled = false # Set to true if you want notifications
  }
}
