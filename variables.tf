variable "subscription_number" {
  description = "Subscription number to use when naming resources."
  type        = number
  nullable    = false
  validation {
    error_message = "The subscription_number must be equal to or greater than 1."
    condition     = var.subscription_number >= 1
  }
}
variable "resource_group_number" {
  description = "Resource group number to use when naming resources."
  type        = number
  nullable    = false
  validation {
    error_message = "The resource_group_number must be between 1 and 980."
    condition     = var.resource_group_number >= 1 && var.resource_group_number <= 980
  }
}
variable "application_name" {
  description = "Name of the application to use when naming resources."
  type        = string
  nullable    = false
  validation {
    error_message = "The application_name must be supplied and cannot be null or empty string."
    condition = (
      can(var.application_name) ? (
        var.application_name != null ? (
          length(var.application_name) > 0
        ) : false # fail if application_name is null
      ) : true    # pass if application_name is not supplied, terraform handles this
    )
  }
}
variable "application_name_short" {
  description = "Short name of the application to use when naming resources eg. for storage account name."
  type        = string
  nullable    = false
  validation {
    error_message = "The application_name_short must be supplied and cannot be null or empty string."
    condition = (
      can(var.application_name_short) ? (
        var.application_name_short != null ? (
          length(var.application_name_short) > 0
        ) : false # fail if application_name_short is null
      ) : true    # pass if application_name_short is not supplied, terraform handles this
    )
  }
}
variable "application_friendly_description" {
  description = "Friendly description of the application to use when naming resources."
  type        = string
  nullable    = false
  validation {
    error_message = "The application_friendly_description must be supplied and cannot be null or empty string."
    condition = (
      can(var.application_friendly_description) ? (
        var.application_friendly_description != null ? (
          length(var.application_friendly_description) > 0
        ) : false # fail if application_friendly_description is null
      ) : true    # pass if application_friendly_description is not supplied, terraform handles this
    )
  }
}
variable "environment_name" {
  description = "Name of the environment to use when naming resources."
  type        = string
  nullable    = false
  validation {
    error_message = "The environment_name must be supplied and cannot be null or empty string."
    condition = (
      can(var.environment_name) ? (
        var.environment_name != null ? (
          length(var.environment_name) > 0
        ) : false # fail if environment_name is null
      ) : true    # pass if environment_name is not supplied, terraform handles this
    )
  }
}
variable "azure_region" {
  description = "Name of the Azure region to use when naming resources."
  type        = string
  nullable    = false
  default     = "norwayeast"
  validation {
    error_message = "The azure_region must be supplied and cannot be null or empty string."
    condition = (
      can(var.azure_region) ? (
        var.azure_region != null ? (
          length(var.azure_region) > 0
        ) : false # fail if azure_region is null
      ) : true    # pass if azure_region is not supplied, terraform handles this
    )
  }
}
variable "created_by_tag" {
  description = "Tag to use when naming resources."
  type        = string
  nullable    = false
  validation {
    error_message = "The created_by_tag must be supplied and cannot be null or empty string."
    condition = (
      can(var.created_by_tag) ? (
        var.created_by_tag != null ? (
          length(var.created_by_tag) > 0
        ) : false # fail if created_by_tag is null
      ) : true    # pass if created_by_tag is not supplied, terraform handles this
    )
  }
}
variable "state_container_name" {
  description = "Name of the state container to use when naming resources."
  type        = string
  nullable    = false
  default     = "terraform-remote-backend-state"
  validation {
    error_message = "The state_container_name must be supplied and cannot be null or empty string."
    condition = (
      can(var.state_container_name) ? (
        var.state_container_name != null ? (
          length(var.state_container_name) > 0
        ) : false # fail if state_container_name is null
      ) : true    # pass if state_container_name is not supplied, terraform handles this
    )
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
  nullable = true
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
        ) : false # fail if default_action is null
      ) : true    # pass if default_action is not supplied, terraform handles this
    )
  }
  validation {
    error_message = "When specifying 'bypass' in 'network_rules' all values must be one of '[Logging, Metrics, AzureServices, None]'."
    condition = (
      can(var.network_rules.bypass) ? (
        var.network_rules.bypass != null ? (
          length(setsubtract(var.network_rules.bypass, ["Logging", "Metrics", "AzureServices", "None"])) == 0
        ) : true # allow bypass to be optional
      ) : true   # pass if default_action is not supplied, terraform handles this
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
        ) : true # allow ip_rules to be optional
      ) : true   # pass if default_action is not supplied, terraform handles this
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
        ) : true # allow virtual_network_subnet_ids to be optional
      ) : true   # pass if default_action is not supplied, terraform handles this
    )
  }
}
