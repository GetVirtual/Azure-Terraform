variable "vm-ne-1" {
  type        = string
  description = "Virtual Machine Name - VM NorthEurope 1"
  default     = "NorthEuropeWeb1"
}

variable "vm-ne-2" {
  type        = string
  description = "Virtual Machine Name - VM NorthEurope 2"
  default     = "NorthEuropeWeb2"
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

variable "costcenter" {
  type        = string
  description = "Value for costcenter tag"
}

