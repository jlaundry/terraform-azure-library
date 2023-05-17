
# base-policy

Terraform module for a simple Azure base policy, that provides a baseline of Activity Log alerts.

These alerts meet (and exceed) the CIS Azure Foundations Benchmark v2.0.0:

| CIS Ref# | CIS Title                                                                           | Azure Monitor Alert Name                          |
|----------|-------------------------------------------------------------------------------------|---------------------------------------------------|
| 5.2.1    | Ensure that Activity Log Alert exists for Create Policy Assignment                  | Create or Update Policy Assignment                |
| 5.2.2    | Ensure that Activity Log Alert exists for Delete Policy Assignment                  | Delete Policy Assignment                          |
| 5.2.3    | Ensure that Activity Log Alert exists for Create or Update Network Security Group   | Create or Update Network Security Group           |
| 5.2.4    | Ensure that Activity Log Alert exists for Delete Network Security Group             | Delete Network Security Group                     |
| 5.2.5    | Ensure that Activity Log Alert exists for Create or Update Security Solution        | Create or Update Security Solution                |
| 5.2.6    | Ensure that Activity Log Alert exists for Delete Security Solution                  | Delete Security Solution                          |
| 5.2.7    | Ensure that Activity Log Alert exists for Create or Update SQL Server Firewall Rule | Create, Update or Delete SQL Server Firewall Rule |
| 5.2.8    | Ensure that Activity Log Alert exists for Delete SQL Server Firewall Rule           | Create, Update or Delete SQL Server Firewall Rule |
| 5.2.9    | Ensure that Activity Log Alert exists for Create or Update Public IP Address rule   | Create or Update Public IP Address                |
| 5.2.10   | Ensure that Activity Log Alert exists for Delete Public IP Address rule             | Delete Public IP Address                          |

## Usage

Import the module into a Terraform project:

```terraform

terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = ">=3.2.0"
    }
  }
}

provider "azurerm" {
  features {}
}

data "azurerm_subscription" "example" {
  subscription_id = "00000000-0000-0000-0000-000000000000"
}

module "azure_base_policy" {
  source          = "github.com/jlaundry/terraform-azure-library/base-policy"

  admin_email     = "admin@example.com"
  subscription_id = data.azurerm_subscription.example.subscription_id
}

```

Run `terraform init && terraform apply`.
