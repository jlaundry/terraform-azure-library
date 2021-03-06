
variable "app_service_plan_name" {
  type = string
}

variable "app_service_plan_rg_name" {
  type = string
}

variable "app_settings" {
  type    = map(string)
  default = {}
}

variable "application_stack" {
  type        = map(string)
  default     = {
    python_version = "3.9"
  }
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
