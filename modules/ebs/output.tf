output "ebs_encryption_by_default_status" {
  description = "Indicates whether EBS encryption by default is enabled"
  value       = try(aws_ebs_encryption_by_default.default[0].enabled, false)
}

output "ebs_encryption_module_enabled" {
  description = "Shows if the EBS encryption module is enabled"
  value       = var.enabled
}
