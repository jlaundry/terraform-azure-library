
variable "env" {
  type = string
}

variable "location" {
  type = string
}

variable "name" {
  type = string
}

variable "os_type" {
  type    = string
  default = "Linux"
}

variable "resource_group_name" {
  type    = string
  default = ""
}

variable "sku_name" {
  type    = string
  default = "B1"
}

variable "tags" {
  type = map(string)
}
