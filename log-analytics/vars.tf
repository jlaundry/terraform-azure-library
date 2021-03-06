
variable "env" {
  type = string
}

variable "instance_id" {
  type    = string
  default = ""
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

variable "tags" {
  type = map(string)
}
