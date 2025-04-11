provider "aws" {
  region = "us-east-1"
}


module "compliance" {
  source               = "./../."
  name                 = "opszero"
  security_hub_enabled = false
  logs_enabled         = false
  ebs_enabled          = false
  guard_duty_enabled   = false
  iam_enabled          = true
}
