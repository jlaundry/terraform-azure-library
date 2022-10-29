
variable "app_settings" {
  type    = map(string)
  default = {}
}

variable "application_stack" {
  type        = map(string)
  default     = {
    python_version = "3.9"
  }
}

variable "auth_enabled" {
  type    = bool
  default = false
}

variable "auth_issuer" {
  type    = string
  default = null
}

variable "auth_aad_client_id" {
  type    = string
  default = ""
}

variable "auth_aad_client_secret" {
  type      = string
  default   = null
  sensitive = true
}

variable "env" {
  type = string
}

variable "github_repository_name" {
  type    = string
  default = ""
}

variable "location" {
  type = string
}

variable "log_retention" {
  type    = number
  default = 30
}

variable "name" {
  type    = string
}

variable "resource_group_name" {
  type    = string
  default = ""
}

variable "suffix" {
  type    = string
  default = ""
}

variable "tags" {
  type = map(string)
}
