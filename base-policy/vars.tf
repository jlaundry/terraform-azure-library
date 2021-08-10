
variable "admin_email" {
    type = string
}

variable "location" {
    type = string
    default = "West US 2"
}

variable "resource_group_name" {
    type = string
    default = "rg-monitor-prod-global"
}

variable "subscription_id" {
    type = string
}
