data "archive_file" "greeter_zip" {
  type        = "zip"
  source_file = "${path.module}/../../lambda/greeter.py"
  output_path = "${path.module}/greeter.zip"
}

resource "aws_lambda_function" "greeter" {

  filename      = data.archive_file.greeter_zip.output_path
  function_name = "greeter-${var.region}"

  role    = aws_iam_role.lambda_role.arn
  handler = "greeter.lambda_handler"
  runtime = "python3.11"

  tracing_config {
    mode = "Active"
  }

  environment {
    variables = {
      TABLE     = aws_dynamodb_table.greetings.name
      SNS_TOPIC = var.sns_topic
      EMAIL     = var.email
      REPO      = var.repo_url
    }
  }
}

data "archive_file" "dispatcher_zip" {
  type        = "zip"
  source_file = "${path.module}/../../lambda/dispatcher.py"
  output_path = "${path.module}/dispatcher.zip"
}

resource "aws_lambda_function" "dispatcher" {

  filename      = data.archive_file.dispatcher_zip.output_path
  function_name = "dispatcher-${var.region}"

  tracing_config {
    mode = "Active"
  }

  environment {
    variables = {
      CLUSTER        = aws_ecs_cluster.cluster.name
      TASK           = aws_ecs_task_definition.dispatch_task.arn
      SUBNET         = aws_subnet.public.id
      SECURITY_GROUP = aws_security_group.ecs_task.id
    }
  }

  role    = aws_iam_role.lambda_role.arn
  handler = "dispatcher.lambda_handler"
  runtime = "python3.11"
}

resource "aws_lambda_permission" "apigw_greeter" {

  statement_id = "AllowAPIGatewayInvokeGreeter"

  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.greeter.function_name

  principal = "apigateway.amazonaws.com"

  source_arn = "${aws_apigatewayv2_api.api.execution_arn}/*/*"
}

resource "aws_lambda_permission" "apigw_dispatcher" {

  statement_id = "AllowAPIGatewayInvokeDispatcher"

  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.dispatcher.function_name

  principal = "apigateway.amazonaws.com"

  source_arn = "${aws_apigatewayv2_api.api.execution_arn}/*/*"
}
