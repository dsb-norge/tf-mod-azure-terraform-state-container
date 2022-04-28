output "resource_group_name" {
  description = "Name of the resource group created for terraform backend state."
  value       = azurerm_resource_group.tfstate.name
}
output "storage_account_name" {
  description = "Name of the storage account created for terraform backend state."
  value       = azurerm_storage_account.tfstate.name
}
output "container_name" {
  description = "Name of the storage container created for terraform backend state."
  value       = azurerm_storage_container.tfstate.name
}
