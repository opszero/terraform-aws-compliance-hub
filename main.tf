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
