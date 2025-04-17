# app-linux

Creates an Azure App Service (Linux) instance.

## Usage

The minimum config required for this module is:

```terraform
module "app" {
  source = "github.com/jlaundry/terraform-azure-library/app-linux"

  name     = "example"
  env      = "dev"
  location = "Australia East"

  ip_allowlist = [
    "0.0.0.0/0",
    "::0/0",
  ]

  tags = {
    "Bla" = "Bla"
  }
}
```

With this, this module will:

  * Create a Resource Group `rg-example-dev-australiaeast`
  * Create an App Service Plan `asp-example-dev-australiaeast`
  * Create the usual Log Analytics workspace, link it to Application Insights, and create Storage Accounts and a KeyVault for the app
  * Create the App Service itself, defaulting to Python 3.12

Other variables include:

  * `app_service_plan_name` and `app_service_plan_rg_name` - if provided, this module will skip creation of a new ASP
  * `app_settings` - if provided, this will be merged with some default settings
  * `application_stack` - defaults to `python_version = "3.12"`
  * `asp_sku_name` - defaults to "B1"
  * `database_url` - which will be stored in KeyVault
  * `github_repository_name` - if provided (and GitHub has been authenticated), this module will create `${upper(var.env)}_AZURE_APP_SERVICE_NAME` and `${upper(var.env)}_AZURE_PUBLISH_PROFILE` GitHub Secrets, for use with a CI/CD Action.
  * `log_retention` - if you want more than 30 days storage in Application Insights
  * `resource_group_name` - if provided, this module will skip creation of a new RG
  * `suffix` - if you want to replace `dev-australiaeast` with something else (why?)
  * `zone_name` and `zone_resource_group_name` - if provided, this module will create the `example.{zone_name}` DNS records, and setup an automatic SSL certificate

## GitHub Action to Deploy

If the `github_repository_name` var has been set, you can use the following example to deploy to the Function automatically:

```yaml
name: Deploy to Dev

on:
  workflow_dispatch:
  push:
    branches: [ main ]

env:
  PYTHON_VERSION: '3.12'

jobs:
  deploy:
    runs-on: ubuntu-latest
    steps:
    - name: Checkout code
      uses: actions/checkout@v4

    - name: Remove unnecessary files
      run: |
        rm -rf ./.deployment
        rm -rf ./.git*
        rm -rf ./.vscode
        rm -rf ./README.md

    - name: Deploy to Azure Functions
      uses: azure/functions-action@v1
      with:
        app-name: ${{ secrets.DEV_AZURE_APP_SERVICE_NAME }}
        publish-profile: ${{ secrets.DEV_AZURE_PUBLISH_PROFILE }}
        scm-do-build-during-deployment: ''
        enable-oryx-build: ''
```
