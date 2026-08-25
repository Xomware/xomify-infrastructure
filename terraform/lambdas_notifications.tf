locals {
  notifications_lambdas = [
    {
      name        = "register"
      description = "Register an iOS device token for APNs push notifications"
      path_part   = "register"
      http_method = "POST"
    },
    {
      name        = "unregister"
      description = "Unregister an iOS device token"
      path_part   = "unregister"
      http_method = "POST"
    },
    # Inbox endpoints (relaunch epic, B3). Serve BOTH clients — web has no APNs
    # token at all, so the inbox is its only notification surface.
    {
      name        = "feed"
      description = "Paginated notification inbox for the caller"
      path_part   = "feed"
      http_method = "GET"
    },
    {
      name        = "read"
      description = "Mark one or all inbox notifications read"
      path_part   = "read"
      http_method = "POST"
    },
    {
      name        = "unread-count"
      description = "Unread notification count for the caller's badge"
      path_part   = "unread-count"
      http_method = "GET"
    },
  ]
}

# HTTP-exposed notification lambdas (register, unregister).
resource "aws_lambda_function" "notifications" {
  for_each         = { for lambda in local.notifications_lambdas : lambda.name => lambda }
  function_name    = "${var.app_name}-notifications-${each.value.name}"
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

  tags = merge(local.standard_tags, tomap({ "name" = "${var.app_name}-notifications-${each.value.name}", "lambda_type" = "notifications" }))

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

# Internal-invoke only: called by shares_react (queue threshold) and cron_shares_digest.
# Not wired to API Gateway.
resource "aws_lambda_function" "notifications_send" {
  function_name    = "${var.app_name}-notifications-send"
  description      = "Send APNs push notifications (internal invoke)"
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

  tags = merge(local.standard_tags, tomap({ "name" = "${var.app_name}-notifications-send", "lambda_type" = "notifications" }))

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

# Internal-invoke only: called by admin_broadcasts_create. Not wired to API
# Gateway.
#
# Separate from the request handler on purpose — reaching every user means a
# full users-table scan plus one dispatch each, which must not happen on the
# admin's request path. Given the fan-out, it gets a longer timeout and more
# memory than the API lambdas.
resource "aws_lambda_function" "notifications_broadcast_fanout" {
  function_name    = "${var.app_name}-notifications-broadcast-fanout"
  description      = "Fan an admin broadcast out to every active user (internal invoke)"
  filename         = "./templates/lambda_stub.zip"
  source_code_hash = filebase64sha256("./templates/lambda_stub.zip")
  handler          = "handler.handler"
  layers           = [aws_lambda_layer_version.lambda_layer.arn]
  runtime          = var.lambda_runtime
  memory_size      = 512
  timeout          = 300
  role             = aws_iam_role.lambda_role.arn

  environment {
    variables = local.lambda_variables
  }

  tracing_config {
    mode = var.lambda_trace_mode
  }

  tags = merge(local.standard_tags, tomap({ "name" = "${var.app_name}-notifications-broadcast-fanout", "lambda_type" = "notifications" }))

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
