locals {
  cron_lambdas = [
    {
      name             = "wrapped"
      description      = "Monthly wrapped generation"
      cron_schedule    = "cron(0 4 1 * ? *)"
      cron_description = "Trigger Wrapped Lambda function on the first day of every month"
    },
    {
      name             = "release-radar"
      description      = "Weekly release radar generation"
      cron_schedule    = "cron(0 11 ? * SAT *)"
      cron_description = "Triggers weekly release radar processing every Saturday at 7 AM Eastern"
    },
    {
      name             = "wrapped-email"
      description      = "Monthly wrapped emails"
      cron_schedule    = "cron(0 12 1 * ? *)"
      cron_description = "Trigger Wrapped Email Lambda function on the first day of every month at 12PM UTC"
    },
    {
      name             = "release-radar-email"
      description      = "Weekly release radar emails"
      cron_schedule    = "cron(0 12 ? * SAT *)"
      cron_description = "Triggers weekly release radar email every Saturday at 8 AM Eastern"
    },
    {
      name             = "shares-digest"
      description      = "Weekly shares digest"
      cron_schedule    = "cron(0 18 ? * SUN *)"
      cron_description = "Triggers weekly shares digest every Sunday at 18:00 UTC (1pm ET / 10am PT)"
    },
    {
      name             = "favorites-reminder"
      description      = "Year-end favorites reminder emails"
      cron_schedule    = "cron(0 14 18 12 ? *)"
      cron_description = "Triggers year-end favorites reminder emails on December 18 at 14:00 UTC"
    },
    {
      name             = "rate-reminder"
      description      = "One nudge, 24h after a share lands unplayed"
      cron_schedule    = "cron(0 17 * * ? *)"
      cron_description = "Daily at 17:00 UTC (1pm ET / 10am PT) — scans shares in the [24h, 48h) window"
    },
    {
      # NOT on the daily schedule, and that is the whole point: the coalesce
      # window is ten minutes. A daily sweep would hold a lone "Sam listened to
      # your song" for up to 24 hours, which is worse than never sending it.
      name             = "notification-sweeper"
      description      = "Drain coalescing rows whose 10-minute window lapsed"
      cron_schedule    = "rate(5 minutes)"
      cron_description = "Every 5 minutes — dispatches parked notifications that never found a sibling"
    },
  ]
}

resource "aws_lambda_function" "cron" {
  for_each         = { for lambda in local.cron_lambdas : lambda.name => lambda }
  function_name    = "${var.app_name}-cron-${each.value.name}"
  description      = each.value.description
  filename         = "./templates/lambda_stub.zip"
  source_code_hash = filebase64sha256("./templates/lambda_stub.zip")
  handler          = "handler.handler"
  layers           = [aws_lambda_layer_version.lambda_layer.arn]
  runtime          = var.lambda_runtime
  memory_size      = var.lambda_memory_size
  timeout          = var.lambda_timeout
  role             = aws_iam_role.cron_lambda_role.arn

  environment {
    variables = local.lambda_variables
  }

  tracing_config {
    mode = var.lambda_trace_mode
  }

  tags = merge(local.standard_tags, tomap({ "name" = "${var.app_name}-cron-${each.value.name}", "lambda_type" = "cron" }))

  lifecycle {
    ignore_changes = [
      description,
      filename,
      source_code_hash,
      layers
    ]
  }

  depends_on = [
    aws_iam_role_policy.cron_lambda_role_policy,
    aws_iam_role.cron_lambda_role
  ]
}

resource "aws_cloudwatch_event_rule" "cron_schedule" {
  for_each            = { for lambda in local.cron_lambdas : lambda.name => lambda }
  name                = "${var.app_name}-${each.value.name}-schedule"
  description         = each.value.cron_description
  schedule_expression = each.value.cron_schedule
}

resource "aws_cloudwatch_event_target" "cron_target" {
  for_each  = { for lambda in local.cron_lambdas : lambda.name => lambda }
  rule      = aws_cloudwatch_event_rule.cron_schedule[each.value.name].name
  target_id = "${var.app_name}-${each.value.name}-target-id"
  arn       = aws_lambda_function.cron[each.value.name].arn
}

resource "aws_lambda_permission" "allow_cloudwatch_cron" {
  for_each      = { for lambda in local.cron_lambdas : lambda.name => lambda }
  statement_id  = "AllowExecutionFromCloudWatch"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.cron[each.value.name].function_name
  principal     = "events.amazonaws.com"
  source_arn    = aws_cloudwatch_event_rule.cron_schedule[each.value.name].arn
}

