
terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = ">= 3.2.0"
    }
    cloudflare = {
      source  = "cloudflare/cloudflare"
    }
    github = {
      source  = "integrations/github"
    }
  }
}

locals {
  instance_id          = var.instance_id != "" ? var.instance_id : random_id.instance_id[0].hex
  instance_name        = "${replace(var.domains[0], ".", "")}-${local.suffix}-${local.instance_id}"
  resource_group_name  = var.resource_group_name != "" ? var.resource_group_name : azurerm_resource_group.rg[0].name
  storage_account_name = "st${substr(replace(var.domains[0], ".", ""), 0, 14)}${local.instance_id}"
  suffix               = "${lower(var.env)}-${replace(lower(var.location), " ", "")}"
}

resource "random_id" "instance_id" {
  count    = var.instance_id == "" ? 1 : 0

  byte_length = 4
}

resource "azurerm_resource_group" "rg" {
  count    = var.resource_group_name == "" ? 1 : 0

  name     = "rg-${local.instance_name}"
  location = var.location

  tags = var.tags
}

data "cloudflare_zones" "zone" {
  filter {
    name = var.cloudflare_zone_name
  }
}

resource "cloudflare_record" "verification" {
  zone_id  = lookup(data.cloudflare_zones.zone.zones[0], "id")
  name     = "asverify.${var.domains[0]}"
  value    = "asverify.${local.storage_account_name}.blob.core.windows.net"
  type     = "CNAME"
  ttl      = 1
  proxied  = false
}

resource "azurerm_storage_account" "public" {
  name                     = local.storage_account_name
  resource_group_name      = local.resource_group_name
  location                 = var.location
  account_tier             = "Standard"
  account_replication_type = "LRS"

  min_tls_version          = "TLS1_2"
  allow_nested_items_to_be_public = true

  static_website {
    index_document = "index.html"
  }

  custom_domain {
    name          = var.domains[0]
    use_subdomain = true
  }

  routing {
    publish_internet_endpoints = true
    choice = "InternetRouting"
  }

  tags = merge(
    {
      Site = var.domains[0]
    },
    var.tags
  )

  depends_on = [
    cloudflare_record.verification
  ]
}

resource "cloudflare_record" "cname" {
  # for_each = toset(slice(var.domains, 1, length(var.domains)))
  for_each = toset(var.domains)

  zone_id  = lookup(data.cloudflare_zones.zone.zones[0], "id")
  name     = each.value
  value    = azurerm_storage_account.public.primary_web_host
  type     = "CNAME"
  ttl      = 1
  proxied  = true
}
