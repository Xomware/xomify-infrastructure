locals {
  broadcasts_lambdas = [
    {
      name        = "active"
      description = "List currently-active broadcasts for any authenticated user"
      path_part   = "active"
      http_method = "GET"
    },
  ]
}

resource "aws_lambda_function" "broadcasts" {
  for_each         = { for lambda in local.broadcasts_lambdas : lambda.name => lambda }
  function_name    = "${var.app_name}-broadcasts-${each.value.name}"
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

  tags = merge(local.standard_tags, tomap({ "name" = "${var.app_name}-broadcasts-${each.value.name}", "lambda_type" = "broadcasts" }))

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
