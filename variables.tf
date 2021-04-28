variable "location" {}

variable "rg_name" {
  type        = string
  default     = "rg1"
  description = "The network interface name"
}

variable "virtual_network_name" {
  type        = string
  default     = "vnet-1"
  description = "The virtual network name"
}

variable "subnet_name" {
  type        = string
  default     = "subnet-1"
  description = "The subnet name"
}

variable "public_ip_name" {
  type        = string
  default     = "public-ip-1"
  description = "The virtual network name"
}

variable "nsg_name" {
  type        = string
  default     = "nsg-1"
  description = "The virtual network name"
}

variable "nic_name" {
  type        = string
  default     = "eth0"
  description = "The network interface name"
}

variable "vm_name" {
  type        = string
  default     = "vm-1"
  description = "The virtual machine name"
}

variable "vm_disk_name" {
  type        = string
  default     = "os-disk-1"
  description = "The disk name of the virtual machine"
}

variable "sku" {
  default = {
    westus2 = "18.04-LTS"
    eastus = "18.04-LTS"
  }
}

variable "admin_username" {
	type = string
	description = "Administrator user name for virtual machine"
}

variable "admin_password" {
	type = string
	description = "Password must meet Azure complexity requirements"
}

variable "mysql_user_name" {
  type        = string
  description = "Mysql username"
}

variable "mysql_user_pass" {
  type        = string
  description = "Mysql user password"
}
