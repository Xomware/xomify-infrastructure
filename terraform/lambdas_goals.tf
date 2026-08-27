locals {
  goals_lambdas = [
    {
      name        = "get"
      description = "Get the caller's weekly goals and week history"
      path_part   = "get"
      http_method = "GET"
    },
    {
      name        = "set"
      description = "Replace the caller's goal set"
      path_part   = "set"
      http_method = "PUT"
    },
    {
      name        = "history-set"
      description = "Record one week's goal outcome (upsert by weekStart)"
      path_part   = "history-set"
      http_method = "POST"
    },
  ]
}

resource "aws_lambda_function" "goals" {
  for_each         = { for lambda in local.goals_lambdas : lambda.name => lambda }
  function_name    = "${var.app_name}-goals-${each.value.name}"
  description      = each.value.description
  filename         = "./templates/lambda_stub.zip"
  source_code_hash = filebase64sha256("./templates/lambda_stub.zip")
  handler          = "handler.handler"
  layers           = [aws_lambda_layer_version.lambda_layer.arn]
  runtime          = var.lambda_runtime
  memory_size      = var.lambda_memory_size
  timeout          = var.lambda_timeout
  role             = aws_iam_role.lambda_role.arn

  environment {
    variables = local.lambda_variables
  }

  tracing_config {
    mode = var.lambda_trace_mode
  }

  tags = merge(local.standard_tags, tomap({ "name" = "${var.app_name}-goals-${each.value.name}", "lambda_type" = "goals" }))

  lifecycle {
    ignore_changes = [
      description,
      filename,
      source_code_hash,
      layers
    ]
  }

  depends_on = [
    aws_iam_role_policy.lambda_role_policy,
    aws_iam_role.lambda_role
  ]
}
