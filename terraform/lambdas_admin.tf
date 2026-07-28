locals {
  admin_lambdas = [
    {
      name        = "broadcasts-create"
      description = "Admin-only: create a broadcast/announcement"
      path_part   = "broadcasts-create"
      http_method = "POST"
    },
    {
      name        = "broadcasts-list"
      description = "Admin-only: list all broadcasts"
      path_part   = "broadcasts-list"
      http_method = "GET"
    },
    {
      name        = "broadcasts-delete"
      description = "Admin-only: delete a broadcast by id"
      path_part   = "broadcasts-delete"
      http_method = "DELETE"
    },
    {
      name        = "health"
      description = "Admin-only: API health rollup from the request log"
      path_part   = "health"
      http_method = "GET"
    },
    {
      name        = "users-list"
      description = "Admin-only: user directory with opt-ins + lastSeen"
      path_part   = "users-list"
      http_method = "GET"
    },
    {
      name        = "user-visits"
      description = "Admin-only: page-visit history for one user"
      path_part   = "user-visits"
      http_method = "GET"
    },
    {
      name        = "crons"
      description = "Admin-only: cron run history"
      path_part   = "crons"
      http_method = "GET"
    },
    {
      name        = "notifications"
      description = "Admin-only: outbound email/push notification log"
      path_part   = "notifications"
      http_method = "GET"
    },
    {
      name        = "view-as"
      description = "Admin-only: read-only impersonation projection for a user"
      path_part   = "view-as"
      http_method = "GET"
    },
  ]
}

resource "aws_lambda_function" "admin" {
  for_each         = { for lambda in local.admin_lambdas : lambda.name => lambda }
  function_name    = "${var.app_name}-admin-${each.value.name}"
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

  tags = merge(local.standard_tags, tomap({ "name" = "${var.app_name}-admin-${each.value.name}", "lambda_type" = "admin" }))

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
