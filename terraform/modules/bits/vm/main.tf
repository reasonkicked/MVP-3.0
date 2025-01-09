resource "azurerm_public_ip" "public_ip" {
  count               = var.public_ip_enabled ? 1 : 0
  name                = "${var.vm_name}-public-ip"
  location            = var.location
  resource_group_name = var.resource_group_name
  allocation_method   = "Static"
}

resource "azurerm_network_interface" "nic" {
  name                = "${var.vm_name}-nic"
  location            = var.location
  resource_group_name = var.resource_group_name

  ip_configuration {
    name                          = "${var.vm_name}-ipconfig"
    subnet_id                     = var.subnet_id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = var.public_ip_enabled ? azurerm_public_ip.public_ip[0].id : null
  }
}

resource "azurerm_linux_virtual_machine" "vm" {
  name                = var.vm_name
  resource_group_name = var.resource_group_name
  location            = var.location
  size                = var.vm_size
  admin_username      = var.admin_username

  admin_ssh_key {
    username   = var.admin_username
    public_key = var.ssh_public_key
  }

  network_interface_ids = [
    azurerm_network_interface.nic.id,
  ]

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "Debian"
    offer     = "debian-12"
    sku       = "12-gen2"
    version   = "latest"
  }

  disable_password_authentication = true
  allow_extension_operations      = true
}

resource "azurerm_virtual_machine_extension" "install_vm_script" {
  name                 = "vm-setup-${var.vm_name}"
  virtual_machine_id   = azurerm_linux_virtual_machine.vm.id
  publisher            = "Microsoft.Azure.Extensions"
  type                 = "CustomScript"
  type_handler_version = "2.1"

  protected_settings = <<PROTECTED_SETTINGS
  {
    "script": "${base64encode(file(var.script_path))}"
  }
  PROTECTED_SETTINGS
}

resource "azurerm_dev_test_global_vm_shutdown_schedule" "shutdown_schedule" {
  virtual_machine_id = azurerm_linux_virtual_machine.vm.id
  location           = var.location
  enabled            = true
  daily_recurrence_time = var.shutdown_time
  timezone              = var.timezone

  notification_settings {
    enabled = var.notification_enabled
  }
}
