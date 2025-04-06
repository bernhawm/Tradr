provider "aws" {
  region = "us-east-2" # Change to your preferred region
}

resource "aws_dynamodb_table" "users_collections" {
  name           = "UsersCollections"
  billing_mode   = "PAY_PER_REQUEST"

  hash_key       = "userId"

  attribute {
    name = "userId"
    type = "S"
  }

  tags = {
    Environment = "dev"
    Project     = "CardCollectionApp"
  }
}
