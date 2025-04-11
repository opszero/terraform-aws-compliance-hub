output "org_id" {
  value       = var.iam_enabled ? aws_organizations_organization.main[0].id : null
  description = "The AWS Organization ID."
}

output "org_roots" {
  value       = var.iam_enabled ? aws_organizations_organization.main[0].roots : []
  description = "List of root accounts in the organization."
}

output "scp_policy_id" {
  value       = length(aws_organizations_policy.force_mfa_scp) > 0 ? aws_organizations_policy.force_mfa_scp[0].id : null
  description = "The ID of the SCP MFA policy"
}

output "scp_attachment_target_id" {
  value       = var.iam_enabled ? aws_organizations_policy_attachment.attach_force_mfa[0].target_id : null
  description = "Target ID for the attached SCP."
}

output "iam_enforce_mfa_policy_arn" {
  value       = var.iam_enabled ? aws_iam_policy.enforce_mfa[0].arn : null
  description = "ARN of the enforced MFA IAM policy."
}

output "mfa_required_group_name" {
  value       = var.iam_enabled ? aws_iam_group.mfa_required_group[0].name : null
  description = "Name of the MFA required group."
}

output "lambda_execution_role_arn" {
  value       = var.iam_enabled ? aws_iam_role.lambda_execution_role[0].arn : null
  description = "Lambda execution role ARN."
}

output "lambda_policy_arn" {
  value       = var.iam_enabled ? aws_iam_policy.lambda_policy[0].arn : null
  description = "Lambda policy ARN."
}

output "lambda_function_name" {
  value       = length(aws_lambda_function.mfa_enforcer) > 0 ? aws_lambda_function.mfa_enforcer[0].function_name : null
  description = "Name of the Lambda function for MFA enforcement"
}

output "lambda_function_arn" {
  value       = length(aws_lambda_function.mfa_enforcer) > 0 ? aws_lambda_function.mfa_enforcer[0].arn : null
  description = "ARN of the Lambda function for MFA enforcement"
}

output "cloudwatch_event_rule_name" {
  value       = var.iam_enabled ? aws_cloudwatch_event_rule.user_created[0].name : null
  description = "Name of the CloudWatch event rule."
}

output "cloudtrail_name" {
  value       = var.iam_enabled ? aws_cloudtrail.org_trail[0].name : null
  description = "Name of the CloudTrail trail."
}

output "cloudtrail_bucket_name" {
  value       = var.iam_enabled ? aws_s3_bucket.cloudtrail_logs[0].bucket : null
  description = "CloudTrail logs S3 bucket name."
}

output "cloudtrail_bucket_policy" {
  value       = length(aws_s3_bucket_policy.cloudtrail_policy) > 0 ? aws_s3_bucket_policy.cloudtrail_policy[0].id : null
  description = "The ID of the CloudTrail bucket policy, or null if not created."
}

output "iam_password_policy_min_length" {
  value       = var.iam_enabled ? aws_iam_account_password_policy.password_policy[0].minimum_password_length : null
  description = "Minimum password length."
}

output "iam_password_policy_require_symbols" {
  value       = var.iam_enabled ? aws_iam_account_password_policy.password_policy[0].require_symbols : null
  description = "Require symbols in password policy."
}

output "iam_password_policy_max_age" {
  value       = var.iam_enabled ? aws_iam_account_password_policy.password_policy[0].max_password_age : null
  description = "Maximum password age in the IAM password policy."
}