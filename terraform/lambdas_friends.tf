locals {
  friends_lambdas = [
    {
      name        = "request"
      description = "Request a friend"
      path_part   = "request"
      http_method = "POST"
    },
    {
      name        = "accept"
      description = "Accept a friend request"
      path_part   = "accept"
      http_method = "POST"
    },
    {
      name        = "reject"
      description = "Reject a friend request"
      path_part   = "reject"
      http_method = "POST"
    },
    {
      name        = "all"
      description = "Get all user's friends"
      path_part   = "all"
      http_method = "GET"
    },
    {
      name        = "list"
      description = "List all available friends"
      path_part   = "list"
      http_method = "GET"
    },
    {
      name        = "pending"
      description = "Get all pending friends (outgoing and incoming)"
      path_part   = "pending"
      http_method = "GET"
    },
    {
      name        = "profile"
      description = "Get a friend's profile data"
      path_part   = "profile"
      http_method = "GET"
    },
    {
      name        = "remove"
      description = "Remove a friend"
      path_part   = "remove"
      http_method = "DELETE"
    },
    {
      name        = "wrapped"
      description = "A friend's Wrapped archive, gated on friendship + visibility"
      path_part   = "wrapped"
      http_method = "GET"
    },
    {
      name        = "release-radar"
      description = "A friend's Release Radar, gated on friendship + visibility"
      path_part   = "release-radar"
      http_method = "GET"
    },
    {
      name        = "top-items"
      description = "A friend's top items from cache, gated on friendship + visibility"
      path_part   = "top-items"
      http_method = "GET"
    },
  ]
}

resource "aws_lambda_function" "friends" {
  for_each         = { for lambda in local.friends_lambdas : lambda.name => lambda }
  function_name    = "${var.app_name}-friends-${each.value.name}"
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

  tags = merge(local.standard_tags, tomap({ "name" = "${var.app_name}-friends-${each.value.name}", "lambda_type" = "friends" }))

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