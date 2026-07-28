locals {
  favorites_lambdas = [
    {
      name        = "get"
      description = "Get a caller's favorites for a year (overall + custom lists)"
      path_part   = "get"
      http_method = "GET"
    },
    {
      name        = "list-create"
      description = "Create a custom favorites list for the caller"
      path_part   = "list-create"
      http_method = "POST"
    },
    {
      name        = "list-set"
      description = "Set/replace items on a favorites list and append rank-change history"
      path_part   = "list-set"
      http_method = "PUT"
    },
    {
      name        = "list-history"
      description = "Chronological rank-change history for a favorites list"
      path_part   = "list-history"
      http_method = "GET"
    },
    {
      name        = "recommendations"
      description = "Listening-derived recommendations for a favorites list"
      path_part   = "recommendations"
      http_method = "GET"
    },
    {
      name        = "list-delete"
      description = "Delete a custom favorites list for the caller"
      path_part   = "list-delete"
      http_method = "DELETE"
    },
  ]
}

resource "aws_lambda_function" "favorites" {
  for_each         = { for lambda in local.favorites_lambdas : lambda.name => lambda }
  function_name    = "${var.app_name}-favorites-${each.value.name}"
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

  tags = merge(local.standard_tags, tomap({ "name" = "${var.app_name}-favorites-${each.value.name}", "lambda_type" = "favorites" }))

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
