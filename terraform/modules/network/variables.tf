variable "environment" {
  type = string
}

variable "location" {
  type = string
}

variable "application_name" {
  type    = string
  default = "wf"
}

variable "application_instance" {
  type = string
}

variable "functions" {
  type    = set(string)
  default = []
}


variable "resource_instance" {
  type    = number
  default = "01"
}
