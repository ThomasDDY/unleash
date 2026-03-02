resource "aws_dynamodb_table" "greetings" {

  name         = "GreetingLogs"
  billing_mode = "PAY_PER_REQUEST"

  hash_key = "id"

  attribute {
    name = "id"
    type = "S"
  }

  server_side_encryption {
    enabled = true
    kms_key_arn = aws_kms_key.dynamodb.arn
  }

  point_in_time_recovery {
    enabled = true
  }
}

resource "aws_kms_key" "dynamodb" {
  description = "DynamoDB encryption key"
  deletion_window_in_days = 7
  enable_key_rotation     = true
}