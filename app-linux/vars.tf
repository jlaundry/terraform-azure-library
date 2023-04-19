
variable "app_service_plan_name" {
  type = string
  default = ""
}

variable "app_service_plan_rg_name" {
  type = string
  default = ""
}

variable "app_settings" {
  type    = map(string)
  default = {}
}

variable "application_stack" {
  type        = map(string)
  default     = {
    python_version = "3.10"
  }
}

variable "asp_os_type" {
  type    = string
  default = "Linux"
}

variable "asp_sku_name" {
  type    = string
  default = "B1"
}

variable "database_url" {
  type    = string
  default = ""
}

variable "env" {
  type = string
}

variable "ip_allowlist" {
  type = list(string)
}

variable "location" {
  type = string
}

variable "log_retention" {
  type    = number
  default = 30
}

variable "name" {
  type    = string
}

variable "resource_group_name" {
  type    = string
  default = ""
}

variable "repository_name" {
  type = string
}

variable "suffix" {
  type    = string
  default = ""
}

variable "tags" {
  type = map(string)
}

variable "zone_name" {
  type    = string
  default = ""
}

variable "zone_resource_group_name" {
  type    = string
  default = ""
}
