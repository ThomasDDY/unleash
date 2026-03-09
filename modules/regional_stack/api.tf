resource "aws_apigatewayv2_api" "api" {

  name          = "candidate-api-${var.region}"
  protocol_type = "HTTP"
}

resource "aws_apigatewayv2_integration" "greet" {

  api_id = aws_apigatewayv2_api.api.id

  integration_type = "AWS_PROXY"
  integration_uri  = aws_lambda_function.greeter.invoke_arn
}

resource "aws_apigatewayv2_route" "greet" {

  api_id = aws_apigatewayv2_api.api.id

  route_key = "POST /greet"

  target = "integrations/${aws_apigatewayv2_integration.greet.id}"

  authorization_type = "JWT"

  authorizer_id = aws_apigatewayv2_authorizer.cognito.id
}

resource "aws_apigatewayv2_authorizer" "cognito" {
  api_id           = aws_apigatewayv2_api.api.id
  authorizer_type  = "JWT"
  name             = "cognito-authorizer"
  identity_sources = ["$request.header.Authorization"]

  jwt_configuration {
    audience = [module.cognito.aws_cognito_user_pool_client_id]

    issuer = "https://cognito-idp.${var.region}.amazonaws.com/${module.cognito.aws_cognito_user_pool_id}"
  }
}

output "api_url" {
  value = aws_apigatewayv2_api.api.api_endpoint
}