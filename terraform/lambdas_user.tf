locals {
  user_lambdas = [
    {
      name        = "update"
      description = "Update user"
      path_part   = "update"
      http_method = "POST"
    },
    {
      name        = "trigger-probe"
      description = "TEMPORARY - plan-only probe, never merge"
      path_part   = "trigger-probe"
      http_method = "GET"
    },
    {
      name        = "all"
      description = "Get all users"
      path_part   = "all"
      http_method = "GET"
    },
    {
      name        = "data"
      description = "Get a user's data"
      path_part   = "data"
      http_method = "GET"
    },
    {
      name        = "top-items"
      description = "Live top tracks/artists/genres for the signed-in user (daily DDB cache)"
      path_part   = "top-items"
      http_method = "GET"
    },
  ]
}

resource "aws_lambda_function" "user" {
  for_each         = { for lambda in local.user_lambdas : lambda.name => lambda }
  function_name    = "${var.app_name}-user-${each.value.name}"
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

  tags = merge(local.standard_tags, tomap({ "name" = "${var.app_name}-user-${each.value.name}", "lambda_type" = "user" }))

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