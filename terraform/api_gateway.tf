## API Gateway Account (account-level singleton)

resource "aws_api_gateway_account" "api_gateway_account" {
  cloudwatch_role_arn = aws_iam_role.api_gateway_cloudwatch.arn
}

#**********************
# API Gateway (via reusable module)
#**********************

locals {
  # Build endpoint lists with invoke_arn baked in
  user_endpoints = [
    for l in local.user_lambdas : {
      name        = l.name
      path_part   = l.path_part
      http_method = l.http_method
      invoke_arn  = aws_lambda_function.user[l.name].invoke_arn
    }
  ]

  wrapped_endpoints = [
    for l in local.wrapped_lambdas : {
      name        = l.name
      path_part   = l.path_part
      http_method = l.http_method
      invoke_arn  = aws_lambda_function.wrapped[l.name].invoke_arn
    }
  ]

  friends_endpoints = [
    for l in local.friends_lambdas : {
      name        = l.name
      path_part   = l.path_part
      http_method = l.http_method
      invoke_arn  = aws_lambda_function.friends[l.name].invoke_arn
    }
  ]

  groups_endpoints = [
    for l in local.groups_lambdas : {
      name        = l.name
      path_part   = l.path_part
      http_method = l.http_method
      invoke_arn  = aws_lambda_function.groups[l.name].invoke_arn
    }
  ]

  ratings_endpoints = [
    for l in local.ratings_lambdas : {
      name        = l.name
      path_part   = l.path_part
      http_method = l.http_method
      invoke_arn  = aws_lambda_function.ratings[l.name].invoke_arn
    }
  ]

  release_radar_endpoints = [
    for l in local.release_radar_lambdas : {
      name        = l.name
      path_part   = l.path_part
      http_method = l.http_method
      invoke_arn  = aws_lambda_function.release_radar[l.name].invoke_arn
    }
  ]

  shares_endpoints = [
    for l in local.shares_lambdas : {
      name        = l.name
      path_part   = l.path_part
      http_method = l.http_method
      invoke_arn  = aws_lambda_function.shares[l.name].invoke_arn
    }
  ]

  invites_endpoints = [
    for l in local.invites_lambdas : {
      name        = l.name
      path_part   = l.path_part
      http_method = l.http_method
      invoke_arn  = aws_lambda_function.invites[l.name].invoke_arn
    }
  ]

  notifications_endpoints = [
    for l in local.notifications_lambdas : {
      name        = l.name
      path_part   = l.path_part
      http_method = l.http_method
      invoke_arn  = aws_lambda_function.notifications[l.name].invoke_arn
    }
  ]

  auth_endpoints = [
    for l in local.auth_lambdas : {
      name          = l.name
      path_part     = l.path_part
      http_method   = l.http_method
      invoke_arn    = aws_lambda_function.auth[l.name].invoke_arn
      authorization = l.authorization
    }
  ]

  likes_endpoints = [
    for l in local.likes_lambdas : {
      name        = l.name
      path_part   = l.path_part
      http_method = l.http_method
      invoke_arn  = aws_lambda_function.likes[l.name].invoke_arn
    }
  ]

  users_endpoints = [
    for l in local.users_lambdas : {
      name        = l.name
      path_part   = l.path_part
      http_method = l.http_method
      invoke_arn  = aws_lambda_function.users[l.name].invoke_arn
    }
  ]

  goals_endpoints = [
    for l in local.goals_lambdas : {
      name        = l.name
      path_part   = l.path_part
      http_method = l.http_method
      invoke_arn  = aws_lambda_function.goals[l.name].invoke_arn
    }
  ]

  favorites_endpoints = [
    for l in local.favorites_lambdas : {
      name        = l.name
      path_part   = l.path_part
      http_method = l.http_method
      invoke_arn  = aws_lambda_function.favorites[l.name].invoke_arn
    }
  ]

  broadcasts_endpoints = [
    for l in local.broadcasts_lambdas : {
      name        = l.name
      path_part   = l.path_part
      http_method = l.http_method
      invoke_arn  = aws_lambda_function.broadcasts[l.name].invoke_arn
    }
  ]

  admin_endpoints = [
    for l in local.admin_lambdas : {
      name        = l.name
      path_part   = l.path_part
      http_method = l.http_method
      invoke_arn  = aws_lambda_function.admin[l.name].invoke_arn
    }
  ]

  visits_endpoints = [
    for l in local.visits_lambdas : {
      name        = l.name
      path_part   = l.path_part
      http_method = l.http_method
      invoke_arn  = aws_lambda_function.visits[l.name].invoke_arn
    }
  ]

  # Public/unauthenticated routes. `authorization` is carried through so the
  # module skips the custom JWT authorizer (NONE) rather than inheriting CUSTOM.
  music_endpoints = [
    for l in local.music_lambdas : {
      name          = l.name
      path_part     = l.path_part
      http_method   = l.http_method
      invoke_arn    = aws_lambda_function.music[l.name].invoke_arn
      authorization = l.authorization
    }
  ]
}

module "api" {
  source = "git::https://github.com/domgiordano/api-gateway-service.git?ref=v2.7.1"

  app_name              = var.app_name
  stage_name            = var.api_stage_name
  authorizer_invoke_arn = aws_lambda_function.authorizer.invoke_arn
  authorizer_role_arn   = aws_iam_role.apigw_authorizer_invoke.arn
  tags                  = local.standard_tags
  allow_headers         = local.api_allow_headers
  allow_origin          = var.cors_allowed_origins

  # Custom domain
  domain_name     = local.api_domain_name
  certificate_arn = aws_acm_certificate_validation.api.certificate_arn

  services = {
    user          = { path_prefix = "user", endpoints = local.user_endpoints }
    wrapped       = { path_prefix = "wrapped", endpoints = local.wrapped_endpoints }
    friends       = { path_prefix = "friends", endpoints = local.friends_endpoints }
    groups        = { path_prefix = "groups", endpoints = local.groups_endpoints }
    ratings       = { path_prefix = "ratings", endpoints = local.ratings_endpoints }
    release-radar = { path_prefix = "release-radar", endpoints = local.release_radar_endpoints }
    shares        = { path_prefix = "shares", endpoints = local.shares_endpoints }
    invites       = { path_prefix = "invites", endpoints = local.invites_endpoints }
    notifications = { path_prefix = "notifications", endpoints = local.notifications_endpoints }
    auth          = { path_prefix = "auth", endpoints = local.auth_endpoints }
    likes         = { path_prefix = "likes", endpoints = local.likes_endpoints }
    users         = { path_prefix = "users", endpoints = local.users_endpoints }
    music         = { path_prefix = "music", endpoints = local.music_endpoints }
    favorites     = { path_prefix = "favorites", endpoints = local.favorites_endpoints }
    goals         = { path_prefix = "goals", endpoints = local.goals_endpoints }
    broadcasts    = { path_prefix = "broadcasts", endpoints = local.broadcasts_endpoints }
    admin         = { path_prefix = "admin", endpoints = local.admin_endpoints }
    visits        = { path_prefix = "visits", endpoints = local.visits_endpoints }
  }
}
