data "aws_region" "current" {}
data "aws_partition" "current" {}

locals {
  name            = var.name
  trail_name      = "${local.name}-cloudtrail"
  log_bucket_name = "${local.name}-cloudtrail-logs"

  enabled_standards_arns = flatten([
    var.standards_arns
  ])

  enabled_product_arns = flatten([
    var.product_arns
  ])

  tags = merge(
    var.tags,
    {
      "ManagedBy"  = "opsZero"
      "Repository" = "https://github.com/opszero/terraform-aws-compliance-hub"
    }
  )
}


module "aws_cloudtrail" {

  source             = "./modules/cloudtrail"
  enabled            = var.cloudtrail_enabled
  trail_name         = local.trail_name
  s3_bucket_name     = module.logs.aws_logs_bucket
  log_retention_days = 365
  tags               = local.tags
}


module "logs" {

  source                = "./modules/logs"
  enabled               = var.logs_enabled
  s3_bucket_name        = "${local.name}-aws-logs"
  logging_target_bucket = "${local.name}-aws-logs"
  logging_target_prefix = "/logs/s3/${local.name}-aws-logs"
  default_allow         = true
  force_destroy         = true
  tags                  = local.tags
}

module "aws_logs_logs" {
  source  = "./modules/logs"
  enabled = var.logs_enabled

  s3_bucket_name        = local.log_bucket_name
  logging_target_bucket = "${local.name}-aws-logs"
  default_allow         = false
  allow_s3              = true
  s3_logs_prefix        = "/logs/s3/${local.log_bucket_name}"
  force_destroy         = true
  tags                  = local.tags
}


module "aws_guard_duty" {
  source                       = "./modules/guardduty"
  enabled                      = var.guard_duty_enabled
  guardduty_enable             = true
  enable_s3_protection         = var.enable_s3_protection
  enable_kubernetes_protection = var.enable_kubernetes_protection
  enable_malware_protection    = var.enable_malware_protection
  enable_topic                 = true

  sns-topic-name = "guardduty-sns-topic"
  delivery_policy = jsonencode({
    "http" : {
      "defaultHealthyRetryPolicy" : {
        "minDelayTarget" : 20,
        "maxDelayTarget" : 20,
        "numRetries" : 3,
        "numMaxDelayRetries" : 0,
        "numNoDelayRetries" : 0,
        "numMinDelayRetries" : 0,
        "backoffFunction" : "linear"
      },
      "disableSubscriptionOverrides" : false,
      "defaultThrottlePolicy" : {
        "maxReceivesPerSecond" : 1
      }
    }
  })

  tags = local.tags
}

module "ebs" {
  source                        = "./modules/ebs"
  enable_default_ebs_encryption = true
  enabled                       = var.ebs_enabled
}

module "security_hub" {
  source                 = "./modules/securityhub"
  enabled                = var.security_hub_enabled
  enabled_standards_arns = local.enabled_standards_arns
  enabled_product_arns   = local.enabled_product_arns
}

module "aws_iam" {
  source                = "./modules/iam"
  iam_enabled           = var.iam_enabled
  name                  = var.name
  org_feature_set       = var.org_feature_set
  org_policy_types      = var.org_policy_types
  policy_type_to_enable = var.policy_type_to_enable

  mfa_deny_condition                = var.mfa_deny_condition
  mfa_exception_actions             = var.mfa_exception_actions
  allow_view_account_info_actions   = var.allow_view_account_info_actions
  allow_manage_own_mfa_actions      = var.allow_manage_own_mfa_actions
  allow_change_own_password_actions = var.allow_change_own_password_actions
  deny_if_no_mfa_not_actions        = var.deny_if_no_mfa_not_actions


  handler            = var.handler
  runtime            = var.runtime
  timeout            = var.timeout
  memory_size        = var.memory_size
  lambda_iam_actions = var.lambda_iam_actions
  lambda_log_actions = var.lambda_log_actions

  target_id                      = var.target_id
  lambda_permission_statement_id = var.lambda_permission_statement_id
  lambda_permission_principal    = var.lambda_permission_principal
  sid_put_object                 = var.sid_put_object
  sid_bucket_acl                 = var.sid_bucket_acl
  bucket_acl_condition           = var.bucket_acl_condition
  lambda_policy_description      = var.lambda_policy_description

  include_global_service_events = var.include_global_service_events
  is_multi_region_trail         = var.is_multi_region_trail
  enable_log_file_validation    = var.enable_log_file_validation

  minimum_password_length        = var.minimum_password_length
  require_numbers                = var.require_numbers
  require_uppercase_characters   = var.require_uppercase_characters
  require_lowercase_characters   = var.require_lowercase_characters
  require_symbols                = var.require_symbols
  allow_users_to_change_password = var.allow_users_to_change_password
  max_password_age               = var.max_password_age
  password_reuse_prevention      = var.password_reuse_prevention
  hard_expiry                    = var.hard_expiry
}