
resource "aws_guardduty_detector" "guardduty" {
  count  = var.enabled ? 1 : 0
  enable = var.guardduty_enable
  tags   = var.tags
  datasources {
    s3_logs {
      enable = var.enable_s3_protection
    }
    kubernetes {
      audit_logs {
        enable = var.enable_kubernetes_protection
      }
    }
    malware_protection {
      scan_ec2_instance_with_findings {
        ebs_volumes {
          enable = var.enable_malware_protection
        }
      }
    }
  }
}

resource "aws_sns_topic" "sns_topic" {
  count = var.enabled && var.enable_topic ? 1 : 0
  name  = var.sns-topic-name
  tags  = var.tags

  delivery_policy = var.delivery_policy
}

resource "aws_sns_topic_subscription" "email_subscription" {
  for_each  = var.enabled ? var.subscribers : {}
  topic_arn = join("", aws_sns_topic.sns_topic[*].arn)
  protocol  = var.subscribers[each.key].protocol
  endpoint  = var.subscribers[each.key].endpoint
}

# Create CloudWatch Event Rule to forward GuardDuty findings to the SNS topic
resource "aws_cloudwatch_event_rule" "guardduty_event_rule" {
  count       = var.enabled ? 1 : 0
  name        = "ForwardGuardDutyFindings"
  tags        = var.tags
  description = "Forward GuardDuty findings to SNS Topic"

  event_pattern = var.event_pattern

}

resource "aws_cloudwatch_event_target" "guardduty_event_target" {
  count     = var.enabled ? 1 : 0
  rule      = join("", aws_cloudwatch_event_rule.guardduty_event_rule[*].name)
  target_id = "sns_target"
  arn       = join("", aws_sns_topic.sns_topic[*].arn)

  input_transformer {
    input_paths = {
      "severity" : "$.detail.severity",
      "Account_ID" : "$.detail.accountId",
      "Finding_ID" : "$.detail.id",
      "Finding_Type" : "$.detail.type",
      "region" : "$.region",
      "Finding_description" : "$.detail.description"
    }
    input_template = <<TEMPLATE
"AWS <Account_ID> has a severity <severity> GuardDuty finding type <Finding_Type> in the <region> region."
"Finding Description:"
"<Finding_description>. "
"For more details open the GuardDuty console at https://console.aws.amazon.com/guardduty/home?region=<region>#/findings?search=id%3D<Finding_ID>"
TEMPLATE
  }

}

resource "aws_cloudwatch_event_rule" "sns_rule" {
  count       = var.enabled ? 1 : 0
  name        = "GuardDutySNSSubscription"
  description = "Subscribe SNS topic to CloudWatch Events"
  event_pattern = jsonencode({
    source      = ["aws.sns"],
    detail_type = ["AWS API Call via CloudTrail"],
    resources   = [join("", aws_sns_topic.sns_topic[*].arn)],
  })
}

resource "aws_cloudwatch_event_target" "sns_target" {
  count     = var.enabled ? 1 : 0
  rule      = join("", aws_cloudwatch_event_rule.sns_rule[*].name)
  target_id = "sns_subscription"
  arn       = join("", aws_sns_topic.sns_topic[*].arn)
}

