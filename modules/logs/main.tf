
data "aws_caller_identity" "current" {}
data "aws_partition" "current" {}
data "aws_region" "current" {}

locals {
  bucket_arn                   = "arn:${data.aws_partition.current.partition}:s3:::${var.s3_bucket_name}"
  cloudtrail_effect            = var.default_allow || var.allow_cloudtrail ? "Allow" : "Deny"
  cloudtrail_accounts          = length(var.cloudtrail_accounts) > 0 ? var.cloudtrail_accounts : [data.aws_caller_identity.current.account_id]
  cloudtrail_logs_path         = var.cloudtrail_logs_prefix == "" ? "AWSLogs" : "${var.cloudtrail_logs_prefix}/AWSLogs"
  cloudtrail_account_resources = toset(formatlist("${local.bucket_arn}/${local.cloudtrail_logs_path}/%s/*", local.cloudtrail_accounts))
  cloudtrail_resources         = var.cloudtrail_org_id == "" ? local.cloudtrail_account_resources : setunion(local.cloudtrail_account_resources, ["${local.bucket_arn}/${local.cloudtrail_logs_path}/${var.cloudtrail_org_id}/*"])
  cloudwatch_effect            = var.default_allow || var.allow_cloudwatch ? "Allow" : "Deny"
  cloudwatch_service           = "logs.${data.aws_region.current.name}.amazonaws.com"
  cloudwatch_resource          = "${local.bucket_arn}/${var.cloudwatch_logs_prefix}/*"
  s3_effect                    = var.default_allow || var.allow_s3 ? "Allow" : "Deny"
  s3_resources                 = ["${local.bucket_arn}/${var.s3_logs_prefix}/*"]
}

data "aws_iam_policy_document" "main" {
  statement {
    sid    = "cloudtrail-logs-get-bucket-acl"
    effect = local.cloudtrail_effect
    principals {
      type        = "Service"
      identifiers = ["cloudtrail.amazonaws.com"]
    }
    actions   = ["s3:GetBucketAcl"]
    resources = [local.bucket_arn]
  }

  statement {
    sid    = "cloudtrail-logs-put-object"
    effect = local.cloudtrail_effect
    principals {
      type        = "Service"
      identifiers = ["cloudtrail.amazonaws.com"]
    }
    actions   = ["s3:PutObject"]
    resources = local.cloudtrail_resources
    condition {
      test     = "StringEquals"
      variable = "s3:x-amz-acl"
      values   = ["bucket-owner-full-control"]
    }
  }



  statement {
    sid    = "cloudwatch-logs-get-bucket-acl"
    effect = local.cloudwatch_effect
    principals {
      type        = "Service"
      identifiers = [local.cloudwatch_service]
    }
    actions   = ["s3:GetBucketAcl"]
    resources = [local.bucket_arn]
  }

  statement {
    sid    = "cloudwatch-logs-put-object"
    effect = local.cloudwatch_effect
    principals {
      type        = "Service"
      identifiers = [local.cloudwatch_service]
    }
    actions = ["s3:PutObject"]
    condition {
      test     = "StringEquals"
      variable = "s3:x-amz-acl"
      values   = ["bucket-owner-full-control"]
    }
    resources = [local.cloudwatch_resource]
  }


  statement {
    sid    = "s3-logs-put-object"
    effect = local.s3_effect
    principals {
      type        = "Service"
      identifiers = ["logging.s3.amazonaws.com"]
    }
    actions   = ["s3:PutObject"]
    resources = local.s3_resources
  }


  statement {
    sid    = "enforce-tls-requests-only"
    effect = "Deny"
    principals {
      type        = "AWS"
      identifiers = ["*"]
    }
    actions = ["s3:*"]
    resources = [
      local.bucket_arn,
      "${local.bucket_arn}/*"
    ]
    condition {
      test     = "Bool"
      variable = "aws:SecureTransport"
      values   = ["false"]
    }
  }
}


resource "aws_s3_bucket" "aws_logs" {
  count         = var.enabled ? 1 : 0
  bucket        = var.s3_bucket_name
  force_destroy = var.force_destroy
  tags          = var.tags
}

resource "aws_s3_bucket_policy" "aws_logs" {
  count  = var.enabled ? 1 : 0
  bucket = join("", aws_s3_bucket.aws_logs.*.id)
  policy = data.aws_iam_policy_document.main.json
}

resource "aws_s3_bucket_acl" "aws_logs" {
  count      = var.enabled && var.s3_bucket_acl != null ? 1 : 0
  bucket     = join("", aws_s3_bucket.aws_logs.*.id)
  acl        = var.s3_bucket_acl
  depends_on = [aws_s3_bucket_ownership_controls.aws_logs]
}

resource "aws_s3_bucket_ownership_controls" "aws_logs" {
  count = var.enabled && var.control_object_ownership ? 1 : 0

  bucket = join("", aws_s3_bucket.aws_logs.*.id)

  rule {
    object_ownership = var.object_ownership
  }

  depends_on = [
    aws_s3_bucket_policy.aws_logs,
    aws_s3_bucket_public_access_block.public_access_block,
    aws_s3_bucket.aws_logs
  ]
}

resource "aws_s3_bucket_lifecycle_configuration" "aws_logs" {
  count  = var.enabled ? 1 : 0
  bucket = join("", aws_s3_bucket.aws_logs.*.id)

  rule {
    id     = "expire_all_logs"
    status = var.enable_s3_log_bucket_lifecycle_rule ? "Enabled" : "Disabled"

    filter {}

    expiration {
      days = var.s3_log_bucket_retention
    }

    noncurrent_version_expiration {
      noncurrent_days = var.noncurrent_version_retention
    }
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "aws_logs" {
  count  = var.enabled ? 1 : 0
  bucket = join("", aws_s3_bucket.aws_logs.*.id)

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm     = length(var.kms_master_key_id) > 0 ? "aws:kms" : "AES256"
      kms_master_key_id = length(var.kms_master_key_id) > 0 ? var.kms_master_key_id : null
    }
    bucket_key_enabled = var.bucket_key_enabled
  }
}

resource "aws_s3_bucket_logging" "aws_logs" {
  count = var.enabled && var.logging_target_bucket != "" ? 1 : 0

  bucket = join("", aws_s3_bucket.aws_logs.*.id)

  target_bucket = var.logging_target_bucket
  target_prefix = var.logging_target_prefix
}

resource "aws_s3_bucket_versioning" "aws_logs" {
  count  = var.enabled ? 1 : 0
  bucket = join("", aws_s3_bucket.aws_logs.*.id)
  versioning_configuration {
    status     = var.versioning_status
    mfa_delete = var.enable_mfa_delete ? "Enabled" : null
  }
}

resource "aws_s3_bucket_public_access_block" "public_access_block" {
  count                   = var.enabled && var.create_public_access_block ? 1 : 0
  bucket                  = join("", aws_s3_bucket.aws_logs.*.id)
  block_public_acls       = true
  ignore_public_acls      = true
  block_public_policy     = true
  restrict_public_buckets = true
}