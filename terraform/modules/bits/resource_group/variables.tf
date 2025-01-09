variable "location" {
  default = ""
}

variable "name" {
  default = ""
}

variable "vm_size" {
  description = "The size of the VM instance."
  type        = string
  default     = "Standard_D2ps_v5"
}