locals {
  wrapped_lambdas = [
    {
      name        = "all"
      description = "Get user's wrapped data and history"
      path_part   = "all"
      http_method = "GET"
    },
    {
      name        = "month"
      description = "Get specific month's wrapped data"
      path_part   = "month"
      http_method = "GET"
    },
    {
      name        = "year"
      description = "Get all wrapped data for a specific year"
      path_part   = "year"
      http_method = "GET"
    },
  ]
}

resource "aws_lambda_function" "wrapped" {
  for_each         = { for lambda in local.wrapped_lambdas : lambda.name => lambda }
  function_name    = "${var.app_name}-wrapped-${each.value.name}"
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

  tags = merge(local.standard_tags, tomap({ "name" = "${var.app_name}-wrapped-${each.value.name}", "lambda_type" = "wrapped" }))

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