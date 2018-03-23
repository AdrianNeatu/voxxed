provider "aws" {
  region     = "us-east-1"
  alias = "us_east"
  access_key = ""
  secret_key = ""
}

module "cloudwatch_billing" {
  source = "./cloudwatch-billing"
}