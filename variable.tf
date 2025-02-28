variable "tags" {
  description = "A mapping of tags to CloudTrail resources."
  default     = {}
  type        = map(string)
}


variable "ebs_enabled" {
  description = "Enables Amazon EBS. Defaults to true. Setting this to false will disable EBS."
  default     = true
  type        = bool
}

variable "guard_duty_enabled" {
  description = "Enables AWS GuardDuty. Defaults to true. Setting this to false will disable GuardDuty."
  default     = true
  type        = bool
}

variable "logs_enabled" {
  description = "Enables logging. Defaults to true. Setting this to false will pause logging."
  default     = true
  type        = bool
}

variable "cloudtrail_enabled" {
  description = "Enables AWS CloudTrail. Defaults to true. Setting this to false will disable CloudTrail."
  default     = true
  type        = bool
}

variable "security_hub_enabled" {
  description = "Enables AWS Security Hub. Defaults to true. Setting this to false will disable Security Hub."
  default     = true
  type        = bool
}

variable "name" {
  description = "The name used for identifying resources. This can be used for naming EBS, GuardDuty, and other services."
  type        = string
  default     = "secure"
}

variable "standards_arns" {
  description = "A list of additional ARNs for the Security Hub standards."
  type        = list(string)
  default     = []
}

variable "product_arns" {
  description = "A list of additional ARNs for the Security Hub products."
  type        = list(string)
  default     = []
}

variable "enable_s3_protection" {
  description = "Configure and enable S3 protection. Defaults to `true`."
  type        = bool
  default     = true
}

variable "enable_kubernetes_protection" {
  description = "Configure and enable Kubernetes audit logs as a data source for Kubernetes protection. Defaults to `true`."
  type        = bool
  default     = true
}

variable "enable_malware_protection" {
  description = "Configure and enable Malware Protection as data source for EC2 instances with findings for the detector. Defaults to `true`."
  type        = bool
  default     = true
}