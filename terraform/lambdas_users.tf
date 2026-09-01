locals {
  # `users` (plural) — new service group. Distinct from the existing
  # `user` (singular) group so we don't have to retrofit naming.
  # Used today for likes_public toggle; future user-scoped settings
  # mutations should land here.
  users_lambdas = [
    {
      name        = "set-likes-public"
      description = "Toggle the caller's likes_public flag on the users record"
      path_part   = "likes-public"
      http_method = "POST"
    },
    {
      name        = "set-visibility"
      description = "Set which artefacts friends can see (wrapped, release radar, top items)"
      path_part   = "visibility"
      http_method = "POST"
    },
  ]
}

resource "aws_lambda_function" "users" {
  for_each         = { for lambda in local.users_lambdas : lambda.name => lambda }
  function_name    = "${var.app_name}-users-${each.value.name}"
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

  tags = merge(local.standard_tags, tomap({ "name" = "${var.app_name}-users-${each.value.name}", "lambda_type" = "users" }))

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
