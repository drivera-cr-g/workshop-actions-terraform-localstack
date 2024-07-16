# Uncomment to use a common backend and locked state
# Change "http://localhost:4566" to "http://localstack:4566" to use with GHA

# terraform {
#   backend "s3" {
#     bucket                      = "tfstate"
#     key                         = "terraform.tfstate"
#     region                      = "us-east-1"
#     endpoint                    = "http://localhost:4566"
#     dynamodb_endpoint           = "http://localhost:4566"
#     sts_endpoint                = "http://localhost:4566"
#     dynamodb_table              = "tfstate"
#     skip_credentials_validation = true
#     skip_metadata_api_check     = true
#     force_path_style            = true
#     access_key                  = "test"
#     secret_key                  = "test"
#   }
# }
