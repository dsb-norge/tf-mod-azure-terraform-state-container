locals {
  application_name_full             = "${var.application_name}-terraform"
  application_name_short_full       = "${var.application_name_short}-tf"
  application_name_short_full_alnum = join("", regexall("[[:alnum:]]", local.application_name_short_full))
  environment_name_alnum            = join("", regexall("[[:alnum:]]", var.environment_name))
  resource_group_name               = "rg-ss${var.subscription_number}-${local.application_name_full}-${var.environment_name}"
  storage_account_name              = lower(substr("stss${var.subscription_number}${local.application_name_short_full_alnum}${local.environment_name_alnum}", 0, 24))
  common_tags = {
    ApplicationName = var.application_name
    CreatedBy       = var.created_by_tag
    Environment     = var.environment_name
  }
}
resource "azurerm_resource_group" "tfstate" {
  name     = local.resource_group_name
  location = var.azure_region
  tags     = merge(local.common_tags, { Description = "Resource group with terraform backend state for ${var.application_friendly_description}." })
  lifecycle {
    prevent_destroy = true
    ignore_changes = [
      tags,
    ]
  }
}
resource "azurerm_storage_account" "tfstate" {
  name                     = local.storage_account_name
  resource_group_name      = azurerm_resource_group.tfstate.name
  location                 = var.azure_region
  account_tier             = "Standard"
  account_replication_type = "LRS"
  tags                     = merge(local.common_tags, { Description = "Storage account with terraform backend state for ${var.application_friendly_description}." })
  lifecycle {
    prevent_destroy = true
    ignore_changes = [
      tags,
    ]
  }
}
resource "azurerm_storage_account_network_rules" "tfstate" {
  count                      = var.network_rules != null ? 1 : 0
  storage_account_id         = azurerm_storage_account.tfstate.id
  default_action             = var.network_rules.default_action
  bypass                     = var.network_rules.bypass
  ip_rules                   = var.network_rules.ip_rules
  virtual_network_subnet_ids = var.network_rules.virtual_network_subnet_ids
  # tags not supported
}
resource "azurerm_storage_container" "tfstate" {
  name                  = var.state_container_name
  storage_account_name  = azurerm_storage_account.tfstate.name
  container_access_type = "private"
  # tags not supported
  lifecycle {
    prevent_destroy = true
  }
}
