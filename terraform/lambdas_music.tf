locals {
  music_lambdas = [
    {
      name          = "public-top-items"
      description   = "Public, unauthenticated top tracks/artists/genres for an allowlisted user (daily DDB cache)"
      path_part     = "public-top-items"
      http_method   = "GET"
      authorization = "NONE"
    },
    {
      name          = "public-release-radar"
      description   = "Public unauthenticated weekly release radar for an allowlisted user"
      path_part     = "public-release-radar"
      http_method   = "GET"
      authorization = "NONE"
    },
    {
      name          = "public-wrapped"
      description   = "Public unauthenticated monthly wrapped (hydrated) for an allowlisted user"
      path_part     = "public-wrapped"
      http_method   = "GET"
      authorization = "NONE"
    },
    {
      name          = "public-now-playing"
      description   = "Public unauthenticated currently-playing track for an allowlisted user"
      path_part     = "public-now-playing"
      http_method   = "GET"
      authorization = "NONE"
    },
  ]
}

resource "aws_lambda_function" "music" {
  for_each         = { for lambda in local.music_lambdas : lambda.name => lambda }
  function_name    = "${var.app_name}-${each.value.name}"
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

  tags = merge(local.standard_tags, tomap({ "name" = "${var.app_name}-${each.value.name}", "lambda_type" = "music" }))

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
