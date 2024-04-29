variable "functions" {
  type        = set(string)
  default     = []
  description = "Resulting names will have format <resource_type_prefix>-<var.environment>-<var.application_name>-<var.application_instance>-<var.function>-<var.location_code>-<var.resource_instance>"
}

variable "resource_instance" {
  type    = number
  default = "01"
}

variable "environment" {
  type = string

  validation {
    condition     = contains(["dv", "qa", "pp", "pd"], var.environment)
    error_message = "Only dv, qa, pp, pd values are allowed."
  }

}

variable "location" {
  type        = string
  description = "Global resources must explicitly set null."
}

variable "application_name" {
  type = string

  validation {
    condition     = contains(["mvp", "alerts"], var.application_name)
    error_message = "Only mvp, alerts values are allowed."
  }

  description = ""
}

variable "application_instance" {
  type = string

  validation {
    condition     = can(regex("^sh$|^dv$|^pp$|^pd$|^[a-z]{2}[a-z0-9]{3}$|^[a-z]{2}[a-z0-9]{2}$", var.application_instance))
    error_message = "Only sh, dv, pp, pd or names in xxxx(4 letters for ex gb01) or xxxxx(5 letters for ex weu01) format are allowed - only last two chars can be digits."
  }
  description = ""
}
