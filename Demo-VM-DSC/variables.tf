variable "subid" {
  type        = string
  description = "Azure Subscription ID"
}

variable "vm1-name" {
  type        = string
  description = "Virtual Machine Name"
  default     = "WestEuropeWeb1"
}

variable "costcenter" {
  type        = string
  description = "Value for costcenter tag"
}

variable "username" {
  type        = string
  description = "Username for virtual machine"
}

variable "password" {
  type        = string
  description = "Password for virtual machine"
}

variable "rgname" {
  type        = string
  description = "Name of the ressource group"
}