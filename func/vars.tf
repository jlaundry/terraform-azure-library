
variable "app_settings" {
  type    = map(string)
  default = {}
}

variable "env" {
  type = string
}

variable "linux_fx_version" {
  type    = string
  default = "Python|3.8"
}

variable "location" {
  type = string
}

variable "name" {
  type    = string
}

variable "os_type" {
  type    = string
  default = "linux"
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
