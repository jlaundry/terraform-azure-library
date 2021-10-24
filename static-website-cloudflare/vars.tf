
variable "cloudflare_zone_name" {
  type = string
}

variable "domains" {
  description = "The list of domains for this site. The first is treated as primary."
  type = list(string)
}

variable "env" {
  type = string
}

variable "instance_id" {
  default = ""
  type    = string
}

variable "location" {
  type = string
}

variable "resource_group_name" {
  default = ""
  type    = string
}

variable "tags" {
  type = map(string)
}
