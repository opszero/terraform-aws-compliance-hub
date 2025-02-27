variable "enabled" {
  type        = bool
  default     = true
  description = "Flag to control the module creation."
}

variable "enabled_standards_arns" {
  type    = list(string)
  default = []
}

variable "enabled_product_arns" {
  type    = list(string)
  default = []
}
