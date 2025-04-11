variable "name" {
  description = "Prefix used in naming the IAM policy"
  type        = string
  default     = "MFA"
}

variable "org_feature_set" {
  description = "Feature set for the AWS Organization. Valid values are 'ALL' or 'CONSOLIDATED_BILLING'."
  type        = string
  default     = "ALL"
}

variable "org_policy_types" {
  description = "List of enabled policy types for the AWS Organization. Valid values: 'SERVICE_CONTROL_POLICY', etc."
  type        = list(string)
  default     = ["SERVICE_CONTROL_POLICY"]
}

variable "policy_type_to_enable" {
  description = "Type of policy to enable in the organization"
  type        = string
  default     = "SERVICE_CONTROL_POLICY"
}

variable "mfa_deny_condition" {
  description = "Condition block for denying actions if MFA is not present"
  type        = map(any)
  default = {
    "BoolIfExists" = {
      "aws:MultiFactorAuthPresent" = "false"
    }
  }
}

variable "mfa_exception_actions" {
  description = "List of IAM actions allowed without MFA (e.g., to configure MFA)"
  type        = list(string)
  default = [
    "iam:CreateVirtualMFADevice",
    "iam:EnableMFADevice",
    "iam:ResyncMFADevice",
    "iam:ListMFADevices",
    "iam:GetUser",
    "iam:ChangePassword"
  ]
}

variable "allow_view_account_info_actions" {
  description = "Actions allowed for viewing account information"
  type        = list(string)
  default = [
    "iam:ListAccountAliases",
    "iam:ListUsers",
    "iam:GetAccountSummary",
    "iam:GetUser"
  ]
}

variable "allow_manage_own_mfa_actions" {
  description = "Actions allowed for managing user's own MFA"
  type        = list(string)
  default = [
    "iam:CreateVirtualMFADevice",
    "iam:EnableMFADevice",
    "iam:ResyncMFADevice",
    "iam:ListMFADevices"
  ]
}

variable "allow_change_own_password_actions" {
  description = "Actions allowed for changing own password"
  type        = list(string)
  default = [
    "iam:ChangePassword",
    "iam:UpdateLoginProfile"
  ]
}

variable "deny_if_no_mfa_not_actions" {
  description = "Actions that will not be denied even if MFA is not present"
  type        = list(string)
  default = [
    "iam:CreateVirtualMFADevice",
    "iam:EnableMFADevice",
    "iam:ResyncMFADevice",
    "iam:ListMFADevices",
    "iam:GetUser",
    "iam:ChangePassword",
    "iam:UpdateLoginProfile",
    "iam:ListAccountAliases",
    "iam:ListUsers",
    "iam:GetAccountSummary"
  ]
}

variable "lambda_policy_description" {
  description = "Description for the Lambda IAM policy"
  type        = string
  default     = "IAM permissions for MFA enforcement"
}

variable "lambda_iam_actions" {
  description = "IAM actions to allow in Lambda policy"
  type        = list(string)
  default = [
    "iam:CreateVirtualMFADevice",
    "iam:EnableMFADevice",
    "iam:ListMFADevices",
    "iam:ListUsers",
    "iam:GetUser",
    "iam:UpdateLoginProfile",
    "iam:AttachUserPolicy",
    "iam:AddUserToGroup",
    "iam:PutUserPolicy",
    "iam:GetPolicy",
    "iam:ListAttachedUserPolicies",
    "iam:ListPolicies",
    "iam:CreateLoginProfile"
  ]
}

variable "lambda_log_actions" {
  description = "CloudWatch Logs actions for Lambda"
  type        = list(string)
  default = [
    "logs:CreateLogGroup",
    "logs:CreateLogStream",
    "logs:PutLogEvents"
  ]
}

variable "retention_in_days" {
  description = "Number of days to retain logs in CloudWatch"
  type        = number
  default     = 30
}

variable "lambda_source_file" {
  description = "The path to the source Python file for Lambda"
  type        = string
  default     = "lambda_function.py"
}

variable "lambda_output_path" {
  description = "The output path for the zipped Lambda function"
  type        = string
  default     = "lambda_function.zip"
}

variable "runtime" {
  description = "Lambda runtime"
  type        = string
  default     = "python3.9"
}

variable "timeout" {
  description = "Lambda timeout in seconds"
  type        = number
  default     = 15
}

variable "memory_size" {
  description = "Lambda memory size in MB"
  type        = number
  default     = 256
}

variable "handler" {
  description = "Lambda function handler"
  type        = string
  default     = "lambda_function.lambda_handler"
}

variable "target_id" {
  description = "Identifier for the CloudWatch Event target"
  type        = string
  default     = "lambda"
}

variable "lambda_permission_statement_id" {
  description = "Statement ID for the Lambda permission"
  type        = string
  default     = "AllowExecutionFromEventBridge"
}

variable "lambda_permission_principal" {
  description = "Principal allowed to invoke the Lambda function"
  type        = string
  default     = "events.amazonaws.com"
}

variable "sid_put_object" {
  description = "SID for PutObject permission"
  type        = string
  default     = "AWSCloudTrailWrite"
}

variable "bucket_acl_condition" {
  description = "ACL condition for bucket policy"
  type        = string
  default     = "bucket-owner-full-control"
}

variable "sid_bucket_acl" {
  description = "SID for GetBucketAcl permission"
  type        = string
  default     = "AWSCloudTrailBucketPermissionsCheck"
}

variable "include_global_service_events" {
  description = "Whether to include global service events"
  type        = bool
  default     = false
}

variable "is_multi_region_trail" {
  description = "Whether the trail is created in all regions"
  type        = bool
  default     = false
}

variable "enable_log_file_validation" {
  description = "Whether log file validation is enabled"
  type        = bool
  default     = false
}

variable "minimum_password_length" {
  description = "Minimum number of characters allowed in IAM user passwords"
  type        = number
  default     = 14
}

variable "require_numbers" {
  description = "Whether IAM user passwords must contain at least one number"
  type        = bool
  default     = false
}

variable "require_uppercase_characters" {
  description = "Whether IAM user passwords must contain at least one uppercase character"
  type        = bool
  default     = false
}

variable "require_lowercase_characters" {
  description = "Whether IAM user passwords must contain at least one lowercase character"
  type        = bool
  default     = false
}

variable "require_symbols" {
  description = "Whether IAM user passwords must contain at least one non-alphanumeric character"
  type        = bool
  default     = false
}

variable "allow_users_to_change_password" {
  description = "Whether to allow users to change their own password"
  type        = bool
  default     = false
}

variable "max_password_age" {
  description = "The number of days that an IAM user password is valid"
  type        = number
  default     = 0
}

variable "password_reuse_prevention" {
  description = "The number of previous passwords that IAM users are prevented from reusing"
  type        = number
  default     = 0
}

variable "hard_expiry" {
  description = "Whether users are prevented from setting a new password after their password has expired"
  type        = bool
  default     = false
}

variable "iam_enabled" {
  description = "Enable or disable IAM related resources"
  type        = bool
  default     = true
}