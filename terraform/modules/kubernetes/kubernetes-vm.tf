module "jumpbox" {
  source              = "../../modules/bits/vm"
  vm_name             = "${module.conventions.names.aks.virtual_machine}-jumpbox"
  location            = var.location
  resource_group_name = module.aks_resource_group.name
  subnet_id           = data.terraform_remote_state.network.outputs.public_subnet_id
  vm_size             = "Standard_D2ps_v5"
  admin_username      = "adminuser"
  ssh_public_key      = data.azurerm_key_vault_secret.key_vault_id_rsa.value
  public_ip_enabled   = true
  script_path         = "${path.module}/scripts/vm-jumpbox-setup.sh"
  shutdown_time       = "1800"
  timezone            = "Central European Standard Time"

  source_image_reference = {
    publisher = "Debian"
    offer     = "debian-12"
    sku       = "12-arm64"
    version   = "latest"
  }

}
