# conformity

Terraform module for adding Trend Micro Cloud Conformity to Azure

## Usage

Import the module into a Terraform project:

```terraform
module "conformity" {
  source          = "github.com/jlaundry/terraform-azure-library/conformity"
  secret_end_date = "2022-01-01T00:00:01Z"
}

output "conformity_tenant_id" {
    value = module.conformity.tenant_id
}

output "conformity_client_id" {
    value = module.conformity.client_id
}

output "conformity_client_secret" {
    value = module.conformity.client_secret
    sensitive = true
}
```


Run `terraform init && terraform apply`. The build will fail with an error:

```
│ Error: No service principal found for application ID: "xxxxxxxxxxxxx"
│
│   with module.conformity.data.azuread_service_principal.conformity,
│   on .terraform/modules/conformity/main.tf line 69, in data "azuread_service_principal" "conformity":
│   69: data "azuread_service_principal" "conformity" {
│
```

You will need to go to the Azure portal, and **Grant admin consent** before proceeding. Then, run `terraform apply` again.

Finally, copy the output variables into [the Create Azure Directory page](https://cloudone.trendmicro.com/conformity/add/azure/create-directory), and away you go.
