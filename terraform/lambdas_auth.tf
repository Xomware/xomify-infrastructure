locals {
  auth_lambdas = [
    {
      name          = "login"
      description   = "Mint per-user Xomify JWT from a Spotify access token"
      path_part     = "login"
      http_method   = "POST"
      authorization = "NONE"
    },
    # The Spotify client secret stays server-side: clients send the auth code or refresh
    # token here and these call Spotify's token endpoint on their behalf.
    {
      name          = "spotify-token"
      description   = "Exchange a Spotify auth code for tokens"
      path_part     = "spotify-token"
      http_method   = "POST"
      authorization = "NONE"
    },
    {
      name          = "spotify-refresh"
      description   = "Refresh a Spotify access token"
      path_part     = "spotify-refresh"
      http_method   = "POST"
      authorization = "NONE"
    },
  ]
}

resource "aws_lambda_function" "auth" {
  for_each         = { for lambda in local.auth_lambdas : lambda.name => lambda }
  function_name    = "${var.app_name}-auth-${each.value.name}"
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

  tags = merge(local.standard_tags, tomap({ "name" = "${var.app_name}-auth-${each.value.name}", "lambda_type" = "auth" }))

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
