
variable "log_analytics_resource_group_name" {
  type        = string
  description = "Log Analytics resource group name. Recommended to use Azure Security Center's (if using)"
}

variable "log_analytics_workspace_name" {
  type        = string
  description = "Log Analytics workspace name. Recommended to use Azure Security Center's (if using)"
}

variable "enable_change_tracking" {
  type    = bool
  default = false
}

variable "enable_definition_updates" {
  type    = bool
  default = true
}

variable "enable_logs_collection" {
  type    = bool
  default = false
}

variable "enable_metrics_collection" {
  type    = bool
  default = false
}

variable "enable_monthly_updates" {
  type    = bool
  default = false
}

variable "enable_update_management" {
  type    = bool
  default = false
}

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
  type    = string
  default = "automation"
}

variable "resource_group_name" {
  type    = string
  default = ""
}

variable "sku_name" {
  type    = string
  default = "Basic"
}

variable "tags" {
  type = map(string)
}

# TODO: validation of timezone and update_scope is tricky, because these only need to be set if enable_update_management is true.
# https://discuss.hashicorp.com/t/variable-validation-cross-referential-inputs/16067/2

variable "timezone" {
  type    = string
  default = "UTC"
}

variable "update_schedule" {
  type    = list(object({
    scope      = string
    start_time = string
    week_days  = list(string)
  }))
  default = []
}



variable "update_scope" {
  type        = string
  default     = ""
  description = "scope to apply to automation jobs (i.e., \"subscription/{uuid}\")"
}

variable "update_start_time" {
  type        = string
  default     = "05:00:00"
}
