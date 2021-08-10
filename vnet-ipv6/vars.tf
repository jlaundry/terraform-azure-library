
variable "env" {
    type = string
}

variable "ipv4_prefix" {
    type    = string
    default = "10.0"
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

variable "subnets" {
  type = map(string)
}

variable "tags" {
  type = map(string)
}
