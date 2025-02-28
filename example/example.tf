provider "aws" {
  region = "us-east-1"
}


module "compliance" {
  source               = "git::https://github.com/opszero/terraform-aws-compliance-hub"
  name                 = "opszero"
  security_hub_enabled = true
  logs_enabled         = true
  ebs_enabled          = true
  guard_duty_enabled   = true
}
