
variable "admin_email" {
    type = string
}

variable "administrator_object_id" {
    type = string
}

variable "azure_tenant_id" {
    type = string
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

variable "resource_group_name" {
    type    = string
    default = ""
}

variable "sql_version" {
    type    = string
    default = "12.0"
}

variable "tags" {
  type = map(string)
}
