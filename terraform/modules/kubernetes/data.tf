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

data "azurerm_key_vault_secret" "key_vault_id_rsa" {
  name         = "dev-mgmt-vm-id-rsa-pub"
  key_vault_id = data.azurerm_key_vault.key_vault.id
}