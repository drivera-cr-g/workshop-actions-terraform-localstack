# More information in terraform input variables available at
# https://developer.hashicorp.com/terraform/language/values/variables

# Guide on how to use the variables
# https://upcloud.com/resources/tutorials/terraform-variables

variable "region" {
  type        = string
  description = "The AWS regio to deploy to"
}

# To be declared and environment variable TF_VAR_account_id
variable "account_id" {
  type        = string
  description = "AWS Account ID"
  sensitive   = true
}

variable "secret_key" {
  type        = string
  description = "Secret Key for AWS account"
  default     = "test"
}

variable "endpoint" {
  description = "Localstack default endpoint"
}

variable "s3_bucket" {
  type = string
}

variable "dynamo_tables" {
  type = list(object({
    name         = string
    billing_mode = string
    hash_key     = string
  }))
}

variable "s3_key" {
  type = string
}
