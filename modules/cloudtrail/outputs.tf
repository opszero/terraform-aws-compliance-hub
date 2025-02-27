output "cloudtrail_arn" {
  description = "CloudTrail ARN"
  value       = join("", aws_cloudtrail.main.*.arn)
}

output "cloudtrail_home_region" {
  description = "CloudTrail Home Region"
  value       = join("", aws_cloudtrail.main.*.home_region)
}

output "cloudtrail_id" {
  description = "CloudTrail ID"
  value       = join("", aws_cloudtrail.main.*.id)
}

output "kms_key_arn" {
  description = "KMS Key ARN"
  value       = join("", aws_kms_key.cloudtrail.*.arn)
}