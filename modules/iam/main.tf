resource "aws_organizations_organization" "main" {
  count                = var.iam_enabled ? 1 : 0
  feature_set          = format("%s", var.org_feature_set)
  enabled_policy_types = var.org_policy_types
}

resource "null_resource" "enable_scp" {
  count = var.iam_enabled ? 1 : 0
  provisioner "local-exec" {
    command     = <<EOT
ROOT_ID=$(aws organizations list-roots --query "Roots[0].Id" --output text)
IS_ENABLED=$(aws organizations list-roots --output json | jq -r '.Roots[0].PolicyTypes[] | select(.Type == "${var.policy_type_to_enable}") | .Status')

if [ "$IS_ENABLED" != "ENABLED" ]; then
  echo "🔧 Enabling ${var.policy_type_to_enable}..."
  aws organizations enable-policy-type --root-id $ROOT_ID --policy-type ${var.policy_type_to_enable}
else
  echo "✅ ${var.policy_type_to_enable} already enabled."
fi
EOT
    interpreter = ["/bin/bash", "-c"]
  }

  triggers = {
    always_run = timestamp()
  }

  depends_on = [aws_organizations_organization.main]
}

resource "aws_organizations_policy" "force_mfa_scp" {
  count       = var.iam_enabled ? 1 : 0
  name        = format("%s-ForceMFAForAll", var.name)
  description = "Prevents all IAM users from performing actions unless MFA is enabled"
  type        = var.org_policy_types[0]

  content = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect    = "Deny",
        Action    = "*",
        Resource  = "*",
        Condition = var.mfa_deny_condition
      },
      {
        Effect   = "Allow",
        Action   = var.mfa_exception_actions,
        Resource = "*"
      }
    ]
  })

  depends_on = [null_resource.enable_scp]
}

resource "aws_organizations_policy_attachment" "attach_force_mfa" {
  count      = var.iam_enabled ? 1 : 0
  policy_id  = aws_organizations_policy.force_mfa_scp[0].id
  target_id  = aws_organizations_organization.main[count.index].roots[0].id
  depends_on = [aws_organizations_policy.force_mfa_scp]
}

resource "aws_iam_policy" "enforce_mfa" {
  count       = var.iam_enabled ? 1 : 0
  name        = format("%s-EnforceMFA", var.name)
  description = "Deny all actions unless MFA is enabled"

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Sid      = "AllowViewAccountInfo",
        Effect   = "Allow",
        Action   = var.allow_view_account_info_actions,
        Resource = "*"
      },
      {
        Sid    = "AllowManageOwnMFA",
        Effect = "Allow",
        Action = var.allow_manage_own_mfa_actions,
        Resource = [
          "arn:aws:iam::*:mfa/$${aws:username}",
          "arn:aws:iam::*:user/$${aws:username}"
        ]
      },
      {
        Sid      = "AllowChangeOwnPassword",
        Effect   = "Allow",
        Action   = var.allow_change_own_password_actions,
        Resource = "arn:aws:iam::*:user/$${aws:username}"
      },
      {
        Sid       = "DenyAllExceptListedIfNoMFA",
        Effect    = "Deny",
        NotAction = var.deny_if_no_mfa_not_actions,
        Resource  = "*",
        Condition = var.mfa_deny_condition
      }
    ]
  })
}

resource "aws_iam_group" "mfa_required_group" {
  count = var.iam_enabled ? 1 : 0
  name  = "MFARequired"
}

resource "aws_iam_group_policy_attachment" "mfa_policy_attachment" {
  count      = var.iam_enabled ? 1 : 0
  group      = aws_iam_group.mfa_required_group[count.index].name
  policy_arn = aws_iam_policy.enforce_mfa[count.index].arn
}

data "aws_iam_users" "all_users" {}

resource "aws_iam_user_group_membership" "all_users_in_group" {
  for_each = var.iam_enabled ? toset(data.aws_iam_users.all_users.names) : toset([])
  user     = each.key
  groups   = [aws_iam_group.mfa_required_group[0].name]
  lifecycle {
    ignore_changes = [groups]
  }
}

resource "aws_iam_role" "lambda_execution_role" {
  count = var.iam_enabled ? 1 : 0
  name  = format("%s-lambda_role", var.name)

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Principal = {
          Service = "lambda.amazonaws.com"
        }
        Effect = "Allow"
        Sid    = ""
      }
    ]
  })
}

resource "aws_iam_policy" "lambda_policy" {
  count       = var.iam_enabled ? 1 : 0
  name        = format("%s-lambda_mfa_policy", var.name)
  description = var.lambda_policy_description

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect   = "Allow",
        Action   = var.lambda_iam_actions,
        Resource = "*"
      },
      {
        Effect   = "Allow",
        Action   = var.lambda_log_actions,
        Resource = "arn:aws:logs:*:*:*"
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "lambda_policy_attachment" {
  count      = var.iam_enabled ? 1 : 0
  role       = aws_iam_role.lambda_execution_role[0].name
  policy_arn = aws_iam_policy.lambda_policy[0].arn
}

data "archive_file" "lambda_zip" {
  type        = "zip"
  source_file = "${path.module}/lambda_function.py"
  output_path = "${path.module}/lambda_function.zip"
}

resource "aws_lambda_function" "mfa_enforcer" {
  count            = var.iam_enabled ? 1 : 0
  function_name    = format("%s-ForceMFAForAllUsers", var.name)
  handler          = var.handler
  runtime          = var.runtime
  timeout          = var.timeout
  memory_size      = var.memory_size
  role             = aws_iam_role.lambda_execution_role[0].arn
  filename         = data.archive_file.lambda_zip.output_path
  source_code_hash = data.archive_file.lambda_zip.output_base64sha256

  depends_on = [
    aws_iam_role_policy_attachment.lambda_policy_attachment,
  ]
}

resource "aws_cloudwatch_event_rule" "user_created" {
  count       = var.iam_enabled ? 1 : 0
  name        = format("%s-IAMUserCreatedRule", var.name)
  description = "Trigger when new IAM user is created"
  event_pattern = jsonencode({
    "source" : ["aws.iam"],
    "detail-type" : ["AWS API Call via CloudTrail"],
    "detail" : {
      "eventSource" : ["iam.amazonaws.com"],
      "eventName" : ["CreateUser"]
    }
  })
}

resource "aws_cloudwatch_event_target" "lambda_trigger" {
  count     = var.iam_enabled ? 1 : 0
  rule      = aws_cloudwatch_event_rule.user_created[0].name
  target_id = var.target_id
  arn       = aws_lambda_function.mfa_enforcer[0].arn
}

resource "aws_lambda_permission" "allow_eventbridge" {
  count         = var.iam_enabled ? 1 : 0
  statement_id  = var.lambda_permission_statement_id
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.mfa_enforcer[0].function_name
  principal     = var.lambda_permission_principal
  source_arn    = aws_cloudwatch_event_rule.user_created[0].arn
}

resource "aws_s3_bucket" "cloudtrail_logs" {
  count         = var.iam_enabled ? 1 : 0
  bucket        = format("%s-bucketsdd", lower(var.name))
  force_destroy = true
  tags = {
    Name = "CloudTrail Logs Bucket"
  }
}

resource "aws_s3_bucket_policy" "cloudtrail_policy" {
  count  = var.iam_enabled ? 1 : 0
  bucket = aws_s3_bucket.cloudtrail_logs[0].id

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Sid    = var.sid_put_object
        Effect = "Allow",
        Principal = {
          Service = "cloudtrail.amazonaws.com"
        },
        Action   = "s3:PutObject",
        Resource = "${aws_s3_bucket.cloudtrail_logs[0].arn}/AWSLogs/${data.aws_caller_identity.current.account_id}/*",
        Condition = {
          StringEquals = {
            "s3:x-amz-acl" = var.bucket_acl_condition
          }
        }
      },
      {
        Sid    = var.sid_bucket_acl
        Effect = "Allow",
        Principal = {
          Service = "cloudtrail.amazonaws.com"
        },
        Action   = "s3:GetBucketAcl",
        Resource = aws_s3_bucket.cloudtrail_logs[0].arn
      }
    ]
  })
}

data "aws_caller_identity" "current" {}

resource "aws_cloudtrail" "org_trail" {
  count                         = var.iam_enabled ? 1 : 0
  name                          = format("%s-org-trail", var.name)
  s3_bucket_name                = aws_s3_bucket.cloudtrail_logs[0].id
  include_global_service_events = var.include_global_service_events
  is_multi_region_trail         = var.is_multi_region_trail
  enable_log_file_validation    = var.enable_log_file_validation
}

resource "aws_iam_account_password_policy" "password_policy" {
  count                          = var.iam_enabled ? 1 : 0
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