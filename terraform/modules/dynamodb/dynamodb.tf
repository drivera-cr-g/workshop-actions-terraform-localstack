terraform {
  required_providers {
    aws = {
      source                = "hashicorp/aws"
      version               = ">= 2.7.0"
      configuration_aliases = [aws.localstack]
    }
  }
}

resource "aws_dynamodb_table" "sample_table" {
  provider     = aws.localstack
  name         = var.dynamo_tables[0].name
  billing_mode = var.dynamo_tables[0].billing_mode
  hash_key     = var.dynamo_tables[0].hash_key

  attribute {
    name = var.dynamo_tables[0].hash_key
    type = "S"
  }
}
