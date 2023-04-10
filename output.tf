//  Set AWS ID
data "aws_caller_identity" "current" {}

// Set region
data "aws_region" "current"{}

// Output AWS ID
output "aws_account_id" {
  value = "${data.aws_caller_identity.current.account_id}"
}

// Output AWS region
output "aws_region" {
  value = "${data.aws_region.current}"
}

