#**********************
# GitHub Actions OIDC
# Keyless auth for the frontend and backend deploy workflows (#48)
#**********************

# The provider is account-wide and already exists — every Xomware repo that has
# migrated shares it. Creating it here would fail with EntityAlreadyExists.
data "aws_iam_openid_connect_provider" "github" {
  url = "https://token.actions.githubusercontent.com"
}

# One role per repo rather than one shared role: a token minted by a workflow in
# the frontend repo should not be able to touch lambdas, and vice versa. The
# trust policy is the whole security boundary here, so it is scoped to a single
# repo each time.
locals {
  github_oidc_repos = {
    frontend = var.github_frontend_repo
    backend  = var.github_backend_repo
    ios      = var.github_ios_repo
  }
}

data "aws_iam_policy_document" "github_actions_trust" {
  for_each = local.github_oidc_repos

  statement {
    effect  = "Allow"
    actions = ["sts:AssumeRoleWithWebIdentity"]

    principals {
      type        = "Federated"
      identifiers = [data.aws_iam_openid_connect_provider.github.arn]
    }

    condition {
      test     = "StringEquals"
      variable = "token.actions.githubusercontent.com:aud"
      values   = ["sts.amazonaws.com"]
    }

    # `repo:<org>/<repo>:*` — any ref in that repo. Narrowing to
    # `:ref:refs/heads/master` would be tighter, but the deploy workflows also
    # run via workflow_dispatch from other refs, which that would break.
    condition {
      test     = "StringLike"
      variable = "token.actions.githubusercontent.com:sub"
      values   = ["repo:${each.value}:*"]
    }
  }
}

resource "aws_iam_role" "github_actions" {
  for_each = local.github_oidc_repos

  name               = "${var.app_name}-github-actions-${each.key}"
  assume_role_policy = data.aws_iam_policy_document.github_actions_trust[each.key].json

  tags = merge(local.standard_tags, tomap({ "name" = "${var.app_name}-github-actions-${each.key}" }))
}

#**********************
# Frontend: build, read config from SSM, publish to S3, invalidate CloudFront
#**********************

data "aws_iam_policy_document" "github_actions_frontend" {
  statement {
    sid    = "PublishSite"
    effect = "Allow"
    actions = [
      "s3:PutObject",
      "s3:GetObject",
      "s3:DeleteObject",
      "s3:ListBucket",
    ]
    resources = [
      module.web.s3_bucket_arn,
      "${module.web.s3_bucket_arn}/*",
    ]
  }

  statement {
    sid       = "InvalidateCache"
    effect    = "Allow"
    actions   = ["cloudfront:CreateInvalidation"]
    resources = [module.web.cloudfront_distribution_arn]
  }

  # The deploy reads Spotify credentials and the API id out of SSM to bake into
  # the bundle. Scoped to the two prefixes it actually reads, not ssm:*.
  statement {
    sid     = "ReadBuildConfig"
    effect  = "Allow"
    actions = ["ssm:GetParameter", "ssm:GetParameters"]
    resources = [
      "arn:aws:ssm:${var.aws_region}:${data.aws_caller_identity.web_app_account.account_id}:parameter/${var.app_name}/spotify/*",
      "arn:aws:ssm:${var.aws_region}:${data.aws_caller_identity.web_app_account.account_id}:parameter/${var.app_name}/api/*",
    ]
  }

  # Those parameters are SecureString, so reading them is a KMS decrypt too.
  statement {
    sid       = "DecryptBuildConfig"
    effect    = "Allow"
    actions   = ["kms:Decrypt"]
    resources = [aws_kms_alias.web_app.target_key_arn]
  }
}

resource "aws_iam_role_policy" "github_actions_frontend" {
  name   = "deploy"
  role   = aws_iam_role.github_actions["frontend"].id
  policy = data.aws_iam_policy_document.github_actions_frontend.json
}

#**********************
# Backend: publish the shared layer and push lambda code
#**********************

data "aws_iam_policy_document" "github_actions_backend" {
  # Layer versions are not per-function resources and publish-layer-version
  # cannot be scoped below the layer name.
  statement {
    sid    = "ManageSharedLayer"
    effect = "Allow"
    actions = [
      "lambda:PublishLayerVersion",
      "lambda:ListLayerVersions",
      "lambda:GetLayerVersion",
    ]
    resources = [
      "arn:aws:lambda:${var.aws_region}:${data.aws_caller_identity.web_app_account.account_id}:layer:${var.app_name}-shared-packages",
      "arn:aws:lambda:${var.aws_region}:${data.aws_caller_identity.web_app_account.account_id}:layer:${var.app_name}-shared-packages:*",
    ]
  }

  # Every function this account owns for the app, by name prefix. The deploy
  # only ever touches `${var.app_name}-*`, and scoping this way means a new
  # lambda does not need an IAM change to be deployable.
  statement {
    sid    = "DeployFunctions"
    effect = "Allow"
    actions = [
      "lambda:UpdateFunctionCode",
      "lambda:UpdateFunctionConfiguration",
      "lambda:GetFunction",
      "lambda:GetFunctionConfiguration",
    ]
    resources = [
      "arn:aws:lambda:${var.aws_region}:${data.aws_caller_identity.web_app_account.account_id}:function:${var.app_name}-*",
    ]
  }

  # verify-deploy resolves the latest layer before checking each function.
  statement {
    sid       = "ListLayers"
    effect    = "Allow"
    actions   = ["lambda:ListLayers"]
    resources = ["*"]
  }
}

resource "aws_iam_role_policy" "github_actions_backend" {
  name   = "deploy"
  role   = aws_iam_role.github_actions["backend"].id
  policy = data.aws_iam_policy_document.github_actions_backend.json
}

#**********************
# iOS: read the same build config the web deploy does, and nothing else
#**********************

# The TestFlight workflow bakes the Spotify client id/secret and the API id and
# token into the app at build time. It touches no other AWS resource -- no S3,
# no lambda -- so this role is SSM plus the decrypt those SecureStrings require.
data "aws_iam_policy_document" "github_actions_ios" {
  statement {
    sid     = "ReadBuildConfig"
    effect  = "Allow"
    actions = ["ssm:GetParameter", "ssm:GetParameters"]
    resources = [
      "arn:aws:ssm:${var.aws_region}:${data.aws_caller_identity.web_app_account.account_id}:parameter/${var.app_name}/spotify/*",
      "arn:aws:ssm:${var.aws_region}:${data.aws_caller_identity.web_app_account.account_id}:parameter/${var.app_name}/api/*",
    ]
  }

  statement {
    sid       = "DecryptBuildConfig"
    effect    = "Allow"
    actions   = ["kms:Decrypt"]
    resources = [aws_kms_alias.web_app.target_key_arn]
  }
}

resource "aws_iam_role_policy" "github_actions_ios" {
  name   = "deploy"
  role   = aws_iam_role.github_actions["ios"].id
  policy = data.aws_iam_policy_document.github_actions_ios.json
}
