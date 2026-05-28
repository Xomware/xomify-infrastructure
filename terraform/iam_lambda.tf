# ============================================
# Shared assume role policy for Lambda
# ============================================

data "aws_iam_policy_document" "lambda_assume_role" {
  statement {
    actions = ["sts:AssumeRole"]
    principals {
      type        = "Service"
      identifiers = ["lambda.amazonaws.com"]
    }
  }
}

# ============================================
# Authorizer Lambda IAM Role (#51)
# Minimal permissions — only needs SSM, CloudWatch, KMS
# ============================================

resource "aws_iam_role" "authorizer_role" {
  name               = "${var.app_name}-authorizer-exec"
  tags               = merge(local.standard_tags, tomap({ "name" = "${var.app_name}-authorizer-exec" }))
  assume_role_policy = data.aws_iam_policy_document.lambda_assume_role.json
}

data "aws_iam_policy_document" "authorizer_role_policy" {
  # SSM — read auth parameters
  statement {
    effect = "Allow"
    actions = [
      "ssm:GetParameters",
      "ssm:GetParameter",
      "ssm:GetParametersByPath"
    ]
    resources = [
      "arn:aws:ssm:${var.aws_region}:${data.aws_caller_identity.web_app_account.account_id}:parameter/${var.app_name}/*"
    ]
  }

  # CloudWatch Logs
  statement {
    effect = "Allow"
    actions = [
      "logs:CreateLogGroup",
      "logs:CreateLogStream",
      "logs:PutLogEvents"
    ]
    resources = [
      "arn:aws:logs:${var.aws_region}:${data.aws_caller_identity.web_app_account.account_id}:log-group:/aws/lambda/${var.app_name}-authorizer",
      "arn:aws:logs:${var.aws_region}:${data.aws_caller_identity.web_app_account.account_id}:log-group:/aws/lambda/${var.app_name}-authorizer:*"
    ]
  }

  # X-Ray Tracing
  statement {
    effect = "Allow"
    actions = [
      "xray:PutTraceSegments",
      "xray:PutTelemetryRecords",
      "xray:GetSamplingRules",
      "xray:GetSamplingTargets"
    ]
    resources = ["*"]
  }
}

resource "aws_iam_role_policy" "authorizer_role_policy" {
  name   = "${var.app_name}-authorizer-role-policy"
  role   = aws_iam_role.authorizer_role.id
  policy = data.aws_iam_policy_document.authorizer_role_policy.json
}

# ============================================
# Cron Lambda IAM Role (#51)
# Needs DynamoDB, SES, SSM, KMS, CloudWatch
# ============================================

resource "aws_iam_role" "cron_lambda_role" {
  name               = "${var.app_name}-cron-lambda-exec"
  tags               = merge(local.standard_tags, tomap({ "name" = "${var.app_name}-cron-lambda-exec" }))
  assume_role_policy = data.aws_iam_policy_document.lambda_assume_role.json
}

data "aws_iam_policy_document" "cron_lambda_role_policy" {
  # DynamoDB — scoped to app tables
  statement {
    effect = "Allow"
    actions = [
      "dynamodb:BatchGetItem",
      "dynamodb:GetItem",
      "dynamodb:Query",
      "dynamodb:Scan",
      "dynamodb:BatchWriteItem",
      "dynamodb:PutItem",
      "dynamodb:UpdateItem",
      "dynamodb:DeleteItem",
      "dynamodb:DescribeTable"
    ]
    resources = [
      "arn:aws:dynamodb:${var.aws_region}:${data.aws_caller_identity.web_app_account.account_id}:table/${var.app_name}*",
      "arn:aws:dynamodb:${var.aws_region}:${data.aws_caller_identity.web_app_account.account_id}:table/${var.app_name}*/index/*"
    ]
  }

  # SES — scoped to verified identity (#50)
  statement {
    effect = "Allow"
    actions = [
      "ses:SendEmail",
      "ses:SendRawEmail"
    ]
    resources = [
      "arn:aws:ses:${var.aws_region}:${data.aws_caller_identity.web_app_account.account_id}:identity/${local.domain_name}",
      "arn:aws:ses:${var.aws_region}:${data.aws_caller_identity.web_app_account.account_id}:identity/${var.from_email}"
    ]
  }

  # SSM
  statement {
    effect = "Allow"
    actions = [
      "ssm:GetParameters",
      "ssm:GetParameter",
      "ssm:GetParametersByPath"
    ]
    resources = [
      "arn:aws:ssm:${var.aws_region}:${data.aws_caller_identity.web_app_account.account_id}:parameter/${var.app_name}/*"
    ]
  }

  # KMS — for DynamoDB encryption
  statement {
    effect = "Allow"
    actions = [
      "kms:Decrypt",
      "kms:Encrypt",
      "kms:GenerateDataKey",
      "kms:DescribeKey"
    ]
    resources = [
      aws_kms_key.web_app.arn
    ]
  }

  # CloudWatch Logs
  statement {
    effect = "Allow"
    actions = [
      "logs:CreateLogGroup",
      "logs:CreateLogStream",
      "logs:PutLogEvents"
    ]
    resources = [
      "arn:aws:logs:${var.aws_region}:${data.aws_caller_identity.web_app_account.account_id}:log-group:/aws/lambda/${var.app_name}-cron-*",
      "arn:aws:logs:${var.aws_region}:${data.aws_caller_identity.web_app_account.account_id}:log-group:/aws/lambda/${var.app_name}-cron-*:*"
    ]
  }

  # X-Ray Tracing
  statement {
    effect = "Allow"
    actions = [
      "xray:PutTraceSegments",
      "xray:PutTelemetryRecords",
      "xray:GetSamplingRules",
      "xray:GetSamplingTargets"
    ]
    resources = ["*"]
  }

  # Lambda — invoke notifications-send (cron triggers notification dispatch)
  statement {
    effect  = "Allow"
    actions = ["lambda:InvokeFunction"]
    resources = [
      "arn:aws:lambda:${var.aws_region}:${data.aws_caller_identity.web_app_account.account_id}:function:${var.app_name}-notifications-send"
    ]
  }
}

resource "aws_iam_role_policy" "cron_lambda_role_policy" {
  name   = "${var.app_name}-cron-lambda-role-policy"
  role   = aws_iam_role.cron_lambda_role.id
  policy = data.aws_iam_policy_document.cron_lambda_role_policy.json
}

# ============================================
# API Lambda IAM Role (user, wrapped, friends, groups, ratings, release-radar)
# ============================================

data "aws_iam_policy_document" "api_lambda_assume_role" {
  statement {
    actions = ["sts:AssumeRole"]
    principals {
      type        = "Service"
      identifiers = ["lambda.amazonaws.com", "apigateway.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "lambda_role" {
  name               = "${var.app_name}-lambda-exec"
  tags               = merge(local.standard_tags, tomap({ "name" = "${var.app_name}-lambda-exec" }))
  assume_role_policy = data.aws_iam_policy_document.api_lambda_assume_role.json
}

data "aws_iam_policy_document" "lambda_role_policy" {

  # S3 — scoped to app bucket only
  statement {
    effect = "Allow"
    actions = [
      "s3:PutObject",
      "s3:GetObject",
      "s3:GetObjectTagging",
      "s3:ListBucket",
      "s3:PutObjectTagging",
      "s3:GetBucketLocation",
      "s3:DeleteObject"
    ]
    resources = [
      module.web.s3_bucket_arn,
      "${module.web.s3_bucket_arn}/*"
    ]
  }

  # SSM — scoped to app parameters only
  statement {
    effect = "Allow"
    actions = [
      "ssm:GetParameters",
      "ssm:GetParameter",
      "ssm:GetParametersByPath"
    ]
    resources = [
      "arn:aws:ssm:${var.aws_region}:${data.aws_caller_identity.web_app_account.account_id}:parameter/${var.app_name}/*"
    ]
  }

  # CloudWatch Logs
  statement {
    effect = "Allow"
    actions = [
      "logs:CreateLogGroup",
      "logs:CreateLogStream",
      "logs:PutLogEvents",
      "logs:DescribeLogGroups",
      "logs:DescribeLogStreams"
    ]
    resources = [
      "arn:aws:logs:${var.aws_region}:${data.aws_caller_identity.web_app_account.account_id}:log-group:/aws/lambda/${var.app_name}*",
      "arn:aws:logs:${var.aws_region}:${data.aws_caller_identity.web_app_account.account_id}:log-group:/aws/lambda/${var.app_name}*:*"
    ]
  }

  # KMS — for DynamoDB encryption
  statement {
    effect = "Allow"
    actions = [
      "kms:Decrypt",
      "kms:Encrypt",
      "kms:GenerateDataKey",
      "kms:DescribeKey"
    ]
    resources = [
      aws_kms_key.web_app.arn
    ]
  }

  # Lambda — invoke own functions
  statement {
    effect = "Allow"
    actions = [
      "lambda:InvokeFunction",
      "lambda:GetFunction"
    ]
    resources = [
      "arn:aws:lambda:${var.aws_region}:${data.aws_caller_identity.web_app_account.account_id}:function:${var.app_name}*"
    ]
  }

  # API Gateway — execute API
  statement {
    effect  = "Allow"
    actions = ["execute-api:Invoke"]
    resources = [
      "${module.api.rest_api_execution_arn}/*/*/*"
    ]
  }

  # X-Ray Tracing
  statement {
    effect = "Allow"
    actions = [
      "xray:PutTraceSegments",
      "xray:PutTelemetryRecords",
      "xray:GetSamplingRules",
      "xray:GetSamplingTargets"
    ]
    resources = ["*"]
  }

  # DynamoDB — scoped to app tables
  statement {
    effect = "Allow"
    actions = [
      "dynamodb:BatchGetItem",
      "dynamodb:GetItem",
      "dynamodb:Query",
      "dynamodb:Scan",
      "dynamodb:BatchWriteItem",
      "dynamodb:PutItem",
      "dynamodb:UpdateItem",
      "dynamodb:DeleteItem",
      "dynamodb:DescribeTable"
    ]
    resources = [
      "arn:aws:dynamodb:${var.aws_region}:${data.aws_caller_identity.web_app_account.account_id}:table/${var.app_name}*",
      "arn:aws:dynamodb:${var.aws_region}:${data.aws_caller_identity.web_app_account.account_id}:table/${var.app_name}*/index/*"
    ]
  }

  # SES — scoped to verified identity (#50)
  statement {
    effect = "Allow"
    actions = [
      "ses:SendEmail",
      "ses:SendRawEmail"
    ]
    resources = [
      "arn:aws:ses:${var.aws_region}:${data.aws_caller_identity.web_app_account.account_id}:identity/${local.domain_name}",
      "arn:aws:ses:${var.aws_region}:${data.aws_caller_identity.web_app_account.account_id}:identity/${var.from_email}"
    ]
  }
}

resource "aws_iam_role_policy" "lambda_role_policy" {
  name   = "${var.app_name}-lambda-role-policy"
  role   = aws_iam_role.lambda_role.id
  policy = data.aws_iam_policy_document.lambda_role_policy.json
}
