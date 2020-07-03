variable "subid" {
  type        = string
  description = "Azure Subscription ID"
}

variable "vm-we-1" {
  type        = string
  description = "Virtual Machine Name - VM WestEurope 1"
  default     = "WestEuropeWeb1"
}

variable "vm-we-2" {
  type        = string
  description = "Virtual Machine Name - VM WestEurope 2"
  default     = "WestEuropeWeb2"
}

# Cost Center Tag
variable "costcenter" {
  type        = string
  description = "Value for costcenter tag"
}

