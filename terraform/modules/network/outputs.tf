output "resource_group_name" {
  value = azurerm_resource_group.network_resource_group.name
}

output "public_subnet_id" {
  value = azurerm_subnet.public_subnet.id
}
