data "terraform_remote_state" "network" {
  backend = "azurerm"
  config = {
    resource_group_name  = "ts-rg-01"
    storage_account_name = "mvp30backendsa"
    container_name       = "terraform-states"
    key                  = "${var.environment}-${var.application_instance}/network.tfstate" # Adjust for environment and instance
  }
}

data "azurerm_key_vault" "key_vault" {
  name                = "dev-aks-kv"
  resource_group_name = "ts-rg-01"
}

data "azurerm_key_vault_secret" "key_vault_secret" {
  name         = "dev-mgmt-vm"
  key_vault_id = data.azurerm_key_vault.key_vault.id
}

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

resource "azurerm_windows_virtual_machine" "vm" {
  name                = "ManagementVM"
  resource_group_name = data.terraform_remote_state.network.outputs.resource_group_name
  location            = var.location
  size                = "Standard_DS1_v2"
  admin_username      = "adminuser"
  admin_password      = data.azurerm_key_vault_secret.key_vault_secret.value
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

  vm_agent_platform_updates_enabled = true
}

resource "azurerm_dev_test_global_vm_shutdown_schedule" "shutdown_schedule" {
  virtual_machine_id = azurerm_windows_virtual_machine.vm.id
  location           = var.location
  enabled            = true

  # Shutdown at 18:00 Polish time
  daily_recurrence_time = "1800"
  timezone              = "Central European Standard Time" # Polish time zone

  notification_settings {
    enabled = false # Set to true if you want notifications
  }
}
