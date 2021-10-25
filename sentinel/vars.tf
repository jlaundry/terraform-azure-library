
variable "enable_aad_connector" {
  type    = bool
  default = true
}

variable "enable_asc_connector" {
  type    = bool
  default = true
}

variable "env" {
  type = string
}

variable "location" {
  type = string
}

variable "log_retention" {
  type    = number
  default = 90
}

variable "name" {
  type    = string
  default = "sentinel"
}

variable "resource_group_name" {
  type    = string
  default = ""
}

variable "tags" {
  type = map(string)
}
