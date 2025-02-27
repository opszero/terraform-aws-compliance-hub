
resource "aws_securityhub_account" "main" {
  count = var.enabled ? 1 : 0

}

resource "aws_securityhub_standards_subscription" "standards" {
  for_each      = var.enabled ? toset(var.enabled_standards_arns) : toset([])
  depends_on    = [aws_securityhub_account.main]
  standards_arn = each.key
}

resource "aws_securityhub_product_subscription" "products" {
  for_each    = var.enabled ? toset(var.enabled_product_arns) : toset([])
  depends_on  = [aws_securityhub_account.main]
  product_arn = each.key
}