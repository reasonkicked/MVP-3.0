output "vm_id" {
  description = "ID of the created VM"
  value       = azurerm_linux_virtual_machine.vm.id
}

output "public_ip" {
  description = "Public IP of the VM"
  value       = var.public_ip_enabled ? azurerm_public_ip.public_ip[0].ip_address : null
}
