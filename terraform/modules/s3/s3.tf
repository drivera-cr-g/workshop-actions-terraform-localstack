terraform {
  required_providers {
    aws = {
      source                = "hashicorp/aws"
      version               = ">= 2.7.0"
      configuration_aliases = [aws.localstack]
    }
  }
}

resource "aws_s3_bucket" "output_bucket" {
  provider = aws.localstack
  bucket   = var.s3_bucket
}

resource "aws_s3_object" "terraform_output" {
  provider = aws.localstack
  bucket   = aws_s3_bucket.output_bucket.bucket
  key      = var.key
  content  = var.content
}
