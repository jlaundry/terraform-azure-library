
# base-policy
Terraform module for a simple Azure base policy

## Usage

Import the module into a Terraform project:

```terraform
module "azure_base_policy" {
  source          = "github.com/jlaundry/terraform-azure-library/base-policy"

  admin_email     = "admin@example.com"
  subscription_id = data.azurerm_subscription.current.subscription_id
}

```

Run `terraform init && terraform apply`.
