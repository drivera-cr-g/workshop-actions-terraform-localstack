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

module "dynamodb" {
  source = "./modules/dynamodb"
  providers = {
    aws.localstack = aws.localstack
  }
  dynamo_tables = var.dynamo_tables
}

module "s3" {
  source = "./modules/s3"
  providers = {
    aws.localstack = aws.localstack
  }
  s3_bucket = var.s3_bucket
  content = jsonencode({
    sample_table = module.dynamodb.dynamo_sample_table.name
    bucket       = module.s3.s3_bucket
    logs         = format("%s: The table %s was created, along with the %s bucket", timestamp(), module.dynamodb.dynamo_sample_table.name, module.s3.s3_bucket)
  })
  key = var.s3_key
}
