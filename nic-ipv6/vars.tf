
variable "env" {
    type = string
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

variable "subnet_id" {
  type = string
}

variable "tags" {
  type = map(string)
}
