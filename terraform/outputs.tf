# More information on output values available at
# https://developer.hashicorp.com/terraform/language/values/outputs

# Guide on using terraform outputs
# https://spacelift.io/blog/terraform-output

output "dynamo_sample_table" {
  value = module.dynamodb.dynamo_sample_table
}
