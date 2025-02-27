resource "aws_ebs_encryption_by_default" "default" {
  count   = var.enabled ? 1 : 0
  enabled = var.enable_default_ebs_encryption
}

