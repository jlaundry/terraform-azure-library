# func-linux

Creates an Azure Function (Linux) instance.

## Usage

The minimum config required for this module is:

```terraform
module "func" {
  source = "github.com/jlaundry/terraform-azure-library/func-linux"

  name     = "example"
  env      = "dev"
  location = "Australia East"

  tags = {
    "Bla" = "Bla"
  }
}
```

With this, this module will:

  * Create a Resource Group `rg-example-dev-australiaeast`
  * Create the usual Log Analytics workspace, link it to Application Insights, and create Storage Accounts and a KeyVault for the app
  * Create the Function itself, defaulting to Python 3.10

Other variables include:

  * `app_settings` - if provided, this will be merged with some default settings
  * `application_stack` - defaults to `python_version = "3.10"`
  * `auth_enabled` - defaults to false. If set to true, this will add an Azure AD auth setting to the function, using `auth_aad_client_id` and storing `auth_aad_client_secret` in the `MICROSOFT_PROVIDER_AUTHENTICATION_SECRET` app setting
  * `github_repository_name` - if provided (and GitHub has been authenticated), this module will create `${upper(var.env)}_AZURE_APP_SERVICE_NAME` and `${upper(var.env)}_AZURE_PUBLISH_PROFILE` GitHub Secrets, for use with a CI/CD Action.
  * `log_retention` - if you want more than 30 days storage in Application Insights
  * `resource_group_name` - if provided, this module will skip creation of a new RG
  * `suffix` - if you want to replace `dev-australiaeast` with something else (why?)

## GitHub Action to Deploy

If the `github_repository_name` var has been set, you can use the following example to deploy to the Function automatically:

```yaml
name: Deploy to Dev

on:
  workflow_dispatch:
  push:
    branches: [ main ]

env:
  PYTHON_VERSION: '3.10'

jobs:
  deploy:
    runs-on: ubuntu-latest
    steps:
    - name: Checkout code
      uses: actions/checkout@v3

    - name: Remove unnecessary files
      run: |
        rm -rf ./.deployment
        rm -rf ./.git*
        rm -rf ./.vscode
        rm -rf ./README.md

    - name: Deploy to Azure Functions
      uses: azure/functions-action@v1.5.0
      with:
        app-name: ${{ secrets.DEV_AZURE_APP_SERVICE_NAME }}
        publish-profile: ${{ secrets.DEV_AZURE_PUBLISH_PROFILE }}
        scm-do-build-during-deployment: ''
        enable-oryx-build: ''
```
