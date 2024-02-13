variable "application_friendly_description" {
  description = "Friendly description of the application to use when naming resources."
  type        = string
  nullable    = false
  validation {
    error_message = "The 'application_friendly_description' must be supplied and cannot be null or empty string."
    condition     = length(var.application_friendly_description) > 0
  }
}
variable "application_name" {
  description = "Name of the application to use when naming resources."
  type        = string
  nullable    = false
  validation {
    error_message = "The 'application_name' must be supplied and cannot be null or empty string."
    condition     = length(var.application_name) > 0
  }
}
variable "application_name_short" {
  description = "Short name of the application to use when naming resources eg. for storage account name."
  type        = string
  nullable    = false
  validation {
    error_message = "The 'application_name_short' must be supplied and cannot be null or empty string."
    condition     = length(var.application_name_short) > 0
  }
}
variable "created_by_tag" {
  description = "Tag to use when naming resources."
  type        = string
  nullable    = false
  validation {
    error_message = "The 'created_by_tag' must be supplied and cannot be null or empty string."
    condition     = length(var.created_by_tag) > 0
  }
}
variable "environment_name" {
  description = "Name of the environment to use when naming resources."
  type        = string
  nullable    = false
  validation {
    error_message = "The 'environment_name' must be supplied and cannot be null or empty string."
    condition     = length(var.environment_name) > 0
  }
}
variable "resource_group_number" {
  description = "Resource group number to use when naming resources."
  type        = number
  nullable    = false
  validation {
    error_message = "The 'resource_group_number' must be between 1 and 980."
    condition     = var.resource_group_number >= 1 && var.resource_group_number <= 980
  }
}
variable "subscription_number" {
  description = "Subscription number to use when naming resources."
  type        = number
  nullable    = false
  validation {
    error_message = "The 'subscription_number' must be equal to or greater than 1."
    condition     = var.subscription_number >= 1
  }
}
variable "allow_nested_items_to_be_public" {
  description = "Blob anonymous access"
  type        = bool
  nullable    = false
  default     = false
}
variable "azure_region" {
  description = "Name of the Azure region to use when naming resources."
  type        = string
  nullable    = false
  default     = "norwayeast"
  validation {
    error_message = "The 'azure_region' must be supplied and cannot be null or empty string."
    condition     = length(var.azure_region) > 0
  }
}
variable "network_rules" {
  description = "Network rules to apply to the terraform backend state storage account."
  type = object({
    default_action             = string
    bypass                     = list(string)
    ip_rules                   = list(string)
    virtual_network_subnet_ids = list(string)
  })
  #  nullable = true  --> Default value is null, so no need to specify this.
  default = {
    # Default is to allow only DSB public IPs.
    default_action = "Deny"
    # CIDR mask for DSB public IP addresses.
    # Requests from DSB are coming from here, both users and apps hosted in DSBs private datacenters.
    bypass                     = null
    ip_rules                   = ["91.229.21.0/24"]
    virtual_network_subnet_ids = null
  }
  validation {
    error_message = "When specifying 'default_action' in 'network_rules' it must be one of '[Deny, Allow]'."
    condition = (
      can(var.network_rules.default_action) ? (
        var.network_rules.default_action != null ? (
          contains(["Deny", "Allow"], var.network_rules.default_action)
        ) : false # fail if null
      ) : true    # pass if not supplied, terraform handles this
    )
  }
  validation {
    error_message = "When specifying 'bypass' in 'network_rules' all values must be one of '[Logging, Metrics, AzureServices, None]'."
    condition = (
      can(var.network_rules.bypass) ? (
        var.network_rules.bypass != null ? (
          length(setsubtract(var.network_rules.bypass, ["Logging", "Metrics", "AzureServices", "None"])) == 0
        ) : true # allow to be optional
      ) : true   # pass if not supplied, terraform handles this
    )
  }
  validation {
    error_message = "When specifying 'ip_rules' in 'network_rules' all IPs must be valid IPV4 addresses or CIDR masks."
    condition = (
      can(var.network_rules.ip_rules) ? (
        var.network_rules.ip_rules != null ? (
          alltrue([
            for ip in var.network_rules.ip_rules : (
              # must be valid CIDR or IPV4
              can(cidrnetmask(ip))
              || can(regex("^(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\\.(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\\.(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\\.(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)$", ip))
            )
          ])
        ) : true # allow to be optional
      ) : true   # pass if not supplied, terraform handles this
    )
  }
  validation {
    error_message = "When specifying 'virtual_network_subnet_ids' in 'network_rules' no entries can be null and all entries must have length greater than 50."
    condition = (
      can(var.network_rules.virtual_network_subnet_ids) ? (
        var.network_rules.virtual_network_subnet_ids != null ? (
          alltrue([
            for id in var.network_rules.virtual_network_subnet_ids : (
              id != null && length(id) > 50
          )])
        ) : true # allow to be optional
      ) : true   # pass if not supplied, terraform handles this
    )
  }
}
variable "shared_access_key_enabled" {
  description = "Permission to be authorized with the account access key via Shared Key"
  type        = bool
  nullable    = false
  default     = false
}
variable "state_container_name" {
  description = "Name of the state container to use when naming resources."
  type        = string
  nullable    = false
  default     = "terraform-remote-backend-state"
  validation {
    error_message = "The 'state_container_name' must be supplied and cannot be null or empty string."
    condition     = length(var.state_container_name) > 0
  }
}
