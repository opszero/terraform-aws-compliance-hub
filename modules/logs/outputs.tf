output "aws_logs_bucket" {
  description = "ID of the S3 bucket containing AWS logs."
  value       = join("", aws_s3_bucket.aws_logs.*.id)
}


output "s3_bucket_policy" {
  description = "S3 bucket policy"
  value       = data.aws_iam_policy_document.main
}

output "bucket_arn" {
  description = "ARN of the S3 logs bucket"
  value       = join("", aws_s3_bucket.aws_logs.*.arn)
}