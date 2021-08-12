
variable "env" {
  type = string
}

variable "kind" {
  type    = string
  default = "Linux"
}

variable "location" {
  type = string
}

variable "name" {
  type = string
}

variable "resource_group_name" {
  type    = string
  default = ""
}

variable "sku_tier" {
  type    = string
  default = "Basic"
}

variable "sku_size" {
  type    = string
  default = "B1"
}

variable "tags" {
  type = map(string)
}
