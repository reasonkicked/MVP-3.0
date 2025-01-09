variable "vm_name" {
  description = "Name of the VM"
  type        = string
}

variable "location" {
  description = "Location for the resources"
  type        = string
}

variable "resource_group_name" {
  description = "Resource group name"
  type        = string
}

variable "subnet_id" {
  description = "Subnet ID for the VM"
  type        = string
}

variable "vm_size" {
  description = "Size of the VM"
  type        = string
  default     = "Standard_B2s"
}

variable "admin_username" {
  description = "Admin username for the VM"
  type        = string
}

variable "ssh_public_key" {
  description = "SSH public key for authentication"
  type        = string
}

variable "public_ip_enabled" {
  description = "Whether to create a public IP for the VM"
  type        = bool
  default     = false
}

variable "script_path" {
  description = "Path to the initialization script"
  type        = string
}

variable "shutdown_time" {
  description = "Time for daily VM shutdown (HHMM format)"
  type        = string
}

variable "timezone" {
  description = "Timezone for the shutdown schedule"
  type        = string
  default     = "Central European Standard Time"
}

variable "notification_enabled" {
  description = "Whether to enable notifications for shutdown"
  type        = bool
  default     = false
}
