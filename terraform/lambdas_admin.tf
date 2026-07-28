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
