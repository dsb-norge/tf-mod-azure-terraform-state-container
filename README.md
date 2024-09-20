# tf-mod-azure-terraform-state-container

Terraform module to manage terraform state containers in Azure

## Resources

Where possible the resources are declared with `lifecycle.prevent_destroy = true` to prevent accidental deletion of resources.

The module creates the following resource types in Azure:

| Resource type                | Example name                             | Tags |
| ---------------------------- | ---------------------------------------- | ---- |
| Resource group               | `rg2-ss1-my-first-web-app-terraform-dev` | X    |
| Storage account              | `strg2ss1mwatfdev`                       | X    |
| Storage account network rule | -                                        | -    |
| Storage container            | `terraform-remote-backend-state`         | -    |

**Note:** Example names are based on the [basic example](#basic-example) further down.

### Tags

The resource are tagged as follows:

| Tag             | Value                                                          |
| --------------- | -------------------------------------------------------------- |
| ApplicationName | `var.application_name`                                         |
| CreatedBy       | `var.created_by_tag`                                           |
| Environment     | `var.environment_name`                                         |
| Description     | Hardcoded with `var.application_friendly_description` appended |

## Usage

### Basic example

Example with minimum set of input parameters.

```terraform
provider "azurerm" {
  features {}
}
module "terraform_state_container" {
  source = "git@github.com:dsb-norge/tf-mod-azure-terraform-state-container.git?ref=v0"

  # minimum information necessary
  subscription_number              = 1
  environment_name                 = "dev"
  application_name                 = "my-web-first-app"
  application_name_short           = "mwa" # for storage account name
  application_friendly_description = "the first web app"
  created_by_tag                   = "Person or code repo"
}
```

### Full example

Example with all possible set of input parameters.

```terraform
provider "azurerm" {
  features {}
}
module "terraform_state_container" {
  source = "git@github.com:dsb-norge/tf-mod-azure-terraform-state-container.git?ref=v0"

  # minimum information necessary
  subscription_number              = 1
  environment_name                 = "dev"
  application_name                 = "my-web-first-app"
  application_name_short           = "mwa" # for storage account name
  application_friendly_description = "the first web app"
  created_by_tag                   = "Person or code repo"

  # optional parameters and their defaults
  azure_region         = "norwayeast"
  state_container_name = "terraform-remote-backend-state"
  network_rules = {
    default_action             = "Deny"
    bypass                     = null
    ip_rules                   = ["91.229.21.0/24"] # allow only DSB public IPs
    virtual_network_subnet_ids = null
  }
}
```

## Development

### Validate your code

```shell
  # Init project, run fmt and validate
  terraform init -reconfigure
  terraform fmt -check -recursive
  terraform validate

  # Lint with TFLint, calling script from https://github.com/dsb-norge/terraform-tflint-wrappers
  alias lint='curl -s https://raw.githubusercontent.com/dsb-norge/terraform-tflint-wrappers/main/tflint_linux.sh | bash -s --'
  lint

```

### Generate and inject terraform-docs in README.md

```shell
# go1.17+
go install github.com/terraform-docs/terraform-docs@v0.18.0
export PATH=$PATH:$(go env GOPATH)/bin
terraform-docs markdown table --output-file README.md .
```

### Release

After merge of PR to main use tags to release.

Use semantic versioning, see [semver.org](https://semver.org/). Always push tags and add tag annotations.

#### Patch release

Example of patch release `v1.0.1`:

```bash
git checkout origin/main
git pull origin main
git tag --sort=-creatordate | head -n 5 # review latest release tag to determine which is the next one
git log v1..HEAD --pretty=format:"%s"   # output changes since last release
git tag -a 'v1.0.1'  # add patch tag, add change description
git tag -f -a 'v1.0' # move the minor tag, amend the change description
git tag -f -a 'v1'   # move the major tag, amend the change description
git push origin 'refs/tags/v1.0.1'  # push the new tag
git push -f origin 'refs/tags/v1.0' # force push moved tags
git push -f origin 'refs/tags/v1'   # force push moved tags
```

#### Major release

Same as patch release except that the major version tag is a new one. I.e. we do not need to force tag/push.

Example of major release `v2.0.0`:

```bash
git checkout origin/main
git pull origin main
git tag --sort=-creatordate | head -n 5 # review latest release tag to determine which is the next one
git log v1..HEAD --pretty=format:"%s"   # output changes since last release
git tag -a 'v2.0.0'  # add patch tag, add your change description
git tag -a 'v2.0'    # add minor tag, add your change description
git tag -a 'v0'      # add major tag, add your change description
git push --tags      # push the new tags
```

**Note:** If you are having problems pulling main after a release, try to force fetch the tags: `git fetch --tags -f`.

## terraform-docs

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | ~> 1.0 |
| <a name="requirement_azurerm"></a> [azurerm](#requirement\_azurerm) | >= 3.0.0, < 5.0.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_azurerm"></a> [azurerm](#provider\_azurerm) | 3.91.0 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [azurerm_resource_group.tfstate](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/resource_group) | resource |
| [azurerm_storage_account.tfstate](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/storage_account) | resource |
| [azurerm_storage_account_network_rules.tfstate](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/storage_account_network_rules) | resource |
| [azurerm_storage_container.tfstate](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/storage_container) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_application_friendly_description"></a> [application\_friendly\_description](#input\_application\_friendly\_description) | Friendly description of the application to use when naming resources. | `string` | n/a | yes |
| <a name="input_application_name"></a> [application\_name](#input\_application\_name) | Name of the application to use when naming resources. | `string` | n/a | yes |
| <a name="input_application_name_short"></a> [application\_name\_short](#input\_application\_name\_short) | Short name of the application to use when naming resources eg. for storage account name. | `string` | n/a | yes |
| <a name="input_azure_region"></a> [azure\_region](#input\_azure\_region) | Name of the Azure region to use when naming resources. | `string` | `"norwayeast"` | no |
| <a name="input_costcenter_tag"></a> [costcenter\_tag](#input\_costcenter\_tag) | DSB mandatory tag identifying resource group cost center affiliation.<br>Default value is set to DSB IKT cost center. | `string` | `"142"` | no |
| <a name="input_created_by_tag"></a> [created\_by\_tag](#input\_created\_by\_tag) | Tag to use when naming resources. | `string` | n/a | yes |
| <a name="input_environment_name"></a> [environment\_name](#input\_environment\_name) | Name of the environment to use when naming resources. | `string` | n/a | yes |
| <a name="input_network_rules"></a> [network\_rules](#input\_network\_rules) | Network rules to apply to the terraform backend state storage account. | <pre>object({<br>    default_action             = string<br>    bypass                     = list(string)<br>    ip_rules                   = list(string)<br>    virtual_network_subnet_ids = list(string)<br>  })</pre> | <pre>{<br>  "bypass": null,<br>  "default_action": "Deny",<br>  "ip_rules": [<br>    "91.229.21.0/24"<br>  ],<br>  "virtual_network_subnet_ids": null<br>}</pre> | no |
| <a name="input_state_container_name"></a> [state\_container\_name](#input\_state\_container\_name) | Name of the state container to use when naming resources. | `string` | `"terraform-remote-backend-state"` | no |
| <a name="input_subscription_number"></a> [subscription\_number](#input\_subscription\_number) | Subscription number to use when naming resources. | `number` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_container_id"></a> [container\_id](#output\_container\_id) | The ID of the storage container created for terraform backend state. |
| <a name="output_container_name"></a> [container\_name](#output\_container\_name) | Name of the storage container created for terraform backend state. |
| <a name="output_container_resource_manager_id"></a> [container\_resource\_manager\_id](#output\_container\_resource\_manager\_id) | The Resource Manager ID of the storage container created for terraform backend state. |
| <a name="output_resource_group_name"></a> [resource\_group\_name](#output\_resource\_group\_name) | Name of the resource group created for terraform backend state. |
| <a name="output_storage_account_name"></a> [storage\_account\_name](#output\_storage\_account\_name) | Name of the storage account created for terraform backend state. |
<!-- END_TF_DOCS -->