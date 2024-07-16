# More information on terraform modules available at
# https://developer.hashicorp.com/terraform/language/modules

# Example for lambda
# https://registry.terraform.io/modules/terraform-aws-modules/lambda/aws/latest

provider "aws" {
  alias                       = "localstack"
  region                      = var.region
  skip_credentials_validation = true
  skip_metadata_api_check     = true
  skip_requesting_account_id  = true
  s3_use_path_style           = true
  access_key                  = var.account_id
  secret_key                  = var.secret_key
  token                       = "..."
  endpoints {
    dynamodb       = var.endpoint
    s3             = var.endpoint
    sts            = var.endpoint
    secretsmanager = var.endpoint
  }
}
