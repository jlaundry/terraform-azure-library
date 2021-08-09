
terraform {
  required_providers {
    azuread = {
      source = "hashicorp/azuread"
    }
    azurerm = {
      source = "hashicorp/azurerm"
    }
  }
}

data "azuread_client_config" "current" {
}

data "azurerm_subscription" "primary" {
}

resource "azuread_application" "conformity" {
  display_name               = "Trend Micro Cloud Conformity"

  owners = [
    data.azuread_client_config.current.object_id,
  ]

  required_resource_access {
    resource_app_id = "00000002-0000-0000-c000-000000000000"  # Azure AD Graph

    resource_access {
        id   = "311a71cc-e848-46a1-bdf8-97ff7156d8e6"  # User.Read
        type = "Scope"  # Delegated
    }
    resource_access {
        id   = "c582532d-9d9e-43bd-a97c-2667a28ce295"  # User.Read.All
        type = "Scope"  # Delegated
    }
    resource_access {
        id   = "5778995a-e1bf-45b8-affa-663a9f3f4d04"  # Directory.Read.All
        type = "Scope"  # Delegated
    }
    resource_access {
        id   = "5778995a-e1bf-45b8-affa-663a9f3f4d04"  # Directory.Read.All
        type = "Role"  # Application
    }
  }

  required_resource_access {
    resource_app_id = "00000003-0000-0000-c000-000000000000"  # Microsoft Graph

    resource_access {
        id   = "e1fe6dd8-ba31-4d61-89e7-88639da4683d"  # User.Read
        type = "Scope"  # Delegated
    }
    resource_access {
        id   = "a154be20-db9c-4678-8ab7-66f6cc099a59"  # User.Read.All
        type = "Scope"  # Delegated
    }
    resource_access {
        id   = "df021288-bdef-4463-88db-98f22de89214"  # User.Read.All
        type = "Role"  # Application
    }
    resource_access {
        id   = "7ab1d382-f21e-4acd-a863-ba3e13f7da61"  # Directory.Read.All
        type = "Role"  # Application
    }
  }
}

data "azuread_service_principal" "conformity" {
  application_id = azuread_application.conformity.application_id
}

resource "random_password" "conformity" {
  length           = 32
  special          = false
}

resource "azuread_application_password" "conformity" {
  application_object_id = azuread_application.conformity.id
  description           = "Terraform managed"
  value                 = random_password.conformity.result
  end_date              = var.secret_end_date
}

resource "azurerm_role_definition" "conformity" {
  name        = "Custom: Cloud Conformity"
  scope       = data.azurerm_subscription.primary.id
  description = "Subscription level custom role for Cloud One Conformity access."

  permissions {
    actions     = [
                    "Microsoft.AppConfiguration/configurationStores/ListKeyValue/action",
                    "Microsoft.Network/networkWatchers/queryFlowLogStatus/action",
                    "Microsoft.Web/sites/config/list/Action",
                    "Microsoft.Storage/storageAccounts/queueServices/queues/read"
                ]
    not_actions = []
  }

  assignable_scopes = [
    data.azurerm_subscription.primary.id, # /subscriptions/00000000-0000-0000-0000-000000000000
  ]
}

resource "azurerm_role_assignment" "conformity" {
  scope              = data.azurerm_subscription.primary.id
  role_definition_id = azurerm_role_definition.conformity.role_definition_resource_id
  principal_id       = data.azuread_service_principal.conformity.id
}

resource "azurerm_role_assignment" "reader" {
  scope                = data.azurerm_subscription.primary.id
  role_definition_name = "Reader"
  principal_id         = data.azuread_service_principal.conformity.id
}
