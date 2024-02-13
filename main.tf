locals {
  application_name_full             = "${var.application_name}-terraform"
  application_name_short_full       = "${var.application_name_short}-tf"
  application_name_short_full_alnum = join("", regexall("[[:alnum:]]", local.application_name_short_full))
  environment_name_alnum            = join("", regexall("[[:alnum:]]", var.environment_name))
  resource_group_name               = "rg${var.resource_group_number}-ss${var.subscription_number}-${local.application_name_full}-${var.environment_name}"
  storage_account_name              = lower(substr("strg${var.resource_group_number}ss${var.subscription_number}${local.application_name_short_full_alnum}${local.environment_name_alnum}", 0, 24))
  common_tags = {
    ApplicationName = var.application_name
    CreatedBy       = var.created_by_tag
    Environment     = var.environment_name
  }
}
resource "azurerm_resource_group" "tfstate" {
  location = var.azure_region
  name     = local.resource_group_name
  tags     = merge(local.common_tags, { Description = "Resource group with terraform backend state for ${var.application_friendly_description}." })

  lifecycle {
    ignore_changes = [
      tags,
    ]
    prevent_destroy = true
  }
}
resource "azurerm_storage_account" "tfstate" {
  account_replication_type        = "LRS"
  account_tier                    = "Standard"
  location                        = var.azure_region
  name                            = local.storage_account_name
  resource_group_name             = azurerm_resource_group.tfstate.name
  allow_nested_items_to_be_public = var.allow_nested_items_to_be_public
  shared_access_key_enabled       = var.shared_access_key_enabled
  tags                            = merge(local.common_tags, { Description = "Storage account with terraform backend state for ${var.application_friendly_description}." })

  lifecycle {
    ignore_changes = [
      tags,
    ]
    prevent_destroy = true
  }
}
resource "azurerm_storage_account_network_rules" "tfstate" {
  count = var.network_rules != null ? 1 : 0

  default_action             = var.network_rules.default_action
  storage_account_id         = azurerm_storage_account.tfstate.id
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
