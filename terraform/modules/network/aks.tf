module "aks_resource_group" {
  source = "../../modules/bits/resource_group"

  name     = module.conventions.names.kubernetes_cluster.azurerm_resource_group
  location = var.location
}
