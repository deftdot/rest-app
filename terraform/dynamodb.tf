resource "aws_dynamodb_table" "restaurants_dynamodb" {
  name           = "restaurants"
  billing_mode   = "PAY_PER_REQUEST"
  hash_key       = "name"

  attribute {
    name = "name"
    type = "S"
  }
}

resource "aws_dynamodb_table" "audit_dynamodb" {
  name           = "audit"
  billing_mode   = "PAY_PER_REQUEST"
  hash_key       = "ActionID"

  attribute {
    name = "ActionID"
    type = "S"
  }
}