data "aws_region" "current" {}
data "aws_partition" "current" {}

locals {
  name            = var.name
  trail_name      = "${local.name}-cloudtrail"
  log_bucket_name = "${local.name}-cloudtrail-logs"

  enabled_standards_arns = flatten([
    "arn:aws:securityhub:::ruleset/cis-aws-foundations-benchmark/v/1.2.0",
    "arn:aws:securityhub:${data.aws_region.current.name}::standards/pci-dss/v/3.2.1",
    "arn:${data.aws_partition.current.partition}:securityhub:${data.aws_region.current.name}::standards/aws-foundational-security-best-practices/v/1.0.0",
    var.standards_arns
  ])

  enabled_product_arns = flatten([
    "arn:aws:securityhub:${data.aws_region.current.name}::product/aws/guardduty",
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
  logging_target_bucket = local.log_bucket_name
  logging_target_prefix = "/logs/s3/${local.name}-aws-logs"
  default_allow         = true
  force_destroy         = true
  tags                  = local.tags
}

module "aws_logs_logs" {
  source  = "./modules/logs"
  enabled = var.logs_enabled

  s3_bucket_name = local.log_bucket_name
  default_allow  = false
  allow_s3       = true
  s3_logs_prefix = "/logs/s3/${local.name}-aws-logs"
  force_destroy  = true
  tags           = local.tags
}


module "aws_guard_duty" {
  source                       = "./modules/gaardduty"
  enabled                      = var.guard_duty_enabled
  guardduty_enable             = true
  enable_s3_protection         = true
  enable_kubernetes_protection = true
  enable_malware_protection    = true
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