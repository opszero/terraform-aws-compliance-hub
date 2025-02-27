output "guardduty_detector_id" {
  value = try(aws_guardduty_detector.guardduty[0].id, null)
}

output "sns_topic_arn" {
  value = try(aws_sns_topic.sns_topic[0].arn, null)
}

output "sns_topic_name" {
  value = try(aws_sns_topic.sns_topic[0].name, null)
}

output "cloudwatch_event_rule_name" {
  value = try(aws_cloudwatch_event_rule.guardduty_event_rule[0].name, null)
}

output "cloudwatch_event_target_arn" {
  value = try(aws_cloudwatch_event_target.guardduty_event_target[0].arn, null)
}

output "sns_subscription_arns" {
  value = [for sub in aws_sns_topic_subscription.email_subscription : sub.arn]
}
