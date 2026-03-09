variable "email" {}

resource "aws_cognito_user_pool" "pool" {
  name = "candidate-user-pool"
}

resource "aws_cognito_user_pool_client" "client" {
  name         = "candidate-client"
  user_pool_id = aws_cognito_user_pool.pool.id
}

resource "aws_cognito_user" "user" {

  user_pool_id = aws_cognito_user_pool.pool.id
  username     = var.email

  attributes = {
    email = var.email
  }
}

output "pool_arn" {
  value = aws_cognito_user_pool.pool.arn
}

output "cognito_user_pool_id" {
  value = aws_cognito_user_pool.pool.id
}

output "cognito_user_pool_client_id" {
  value = aws_cognito_user_pool_client.client.id
}