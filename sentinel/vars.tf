
variable "env" {
  type = string
}

variable "location" {
  type = string
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
