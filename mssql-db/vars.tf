
variable "db_name" {
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

variable "mssql_server_name" {
    type    = string
}

variable "resource_group_name" {
    type    = string
}

variable "sku_name" {
    type    = string
    default = "Basic"
}

variable "tags" {
  type = map(string)
}

variable "test_db_name" {
    type    = string
    default = ""
}
