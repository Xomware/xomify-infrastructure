locals {
  domain_name     = "${var.app_name}${var.domain_suffix}"
  api_domain_name = "api.${local.domain_name}"

  # Get the AWS account id
  web_app_account_id = data.aws_caller_identity.web_app_account.account_id

  # Standard tags for all resources
  standard_tags = {
    "source"      = "terraform"
    "app_name"    = var.app_name
    "environment" = var.environment
    "owner"       = var.owner
  }

  # Lambda environment variables
  # CORS_ALLOWED_ORIGINS is the same value the API Gateway module uses for
  # preflight. The lambdas echo the caller's Origin against this list on the REAL
  # response; if the two lists disagreed, a preflight could pass and the response
  # still be rejected by the browser.
  lambda_variables = {
    APP_NAME                         = var.app_name
    CORS_ALLOWED_ORIGINS             = var.cors_allowed_origins
    DYNAMODB_KMS_ALIAS               = aws_kms_alias.dynamodb.name
    USERS_TABLE_NAME                 = aws_dynamodb_table.users.id
    WRAPPED_HISTORY_TABLE_NAME       = aws_dynamodb_table.wrapped_history.id
    RELEASE_RADAR_HISTORY_TABLE_NAME = aws_dynamodb_table.release_radar_history.id
    FRIENDSHIPS_TABLE_NAME           = aws_dynamodb_table.friendships.id
    GROUPS_TABLE_NAME                = aws_dynamodb_table.groups.id
    GROUP_MEMBERS_TABLE_NAME         = aws_dynamodb_table.group_members.id
    GROUP_TRACKS_TABLE_NAME          = aws_dynamodb_table.group_tracks.id
    TRACK_RATINGS_TABLE_NAME         = aws_dynamodb_table.track_ratings.id
    SHARES_TABLE_NAME                = aws_dynamodb_table.shares.id
    SHARE_INTERACTIONS_TABLE_NAME    = aws_dynamodb_table.share_interactions.id
    SHARE_LISTENERS_TABLE_NAME       = aws_dynamodb_table.share_listeners.id
    SHARE_COMMENTS_TABLE_NAME        = aws_dynamodb_table.share_comments.id
    SHARE_REACTIONS_TABLE_NAME       = aws_dynamodb_table.share_reactions.id
    INVITES_TABLE_NAME               = aws_dynamodb_table.invites.id
    DEVICE_TOKENS_TABLE_NAME         = aws_dynamodb_table.device_tokens.id
    TOP_ITEMS_CACHE_TABLE_NAME       = aws_dynamodb_table.top_items_cache.id
    USER_LIKES_TABLE_NAME            = aws_dynamodb_table.user_likes.id
    USER_LIKES_EMAIL_ADDED_INDEX     = "email-addedAt-index"
    FAVORITES_TABLE_NAME             = aws_dynamodb_table.favorites.id
    GOALS_TABLE_NAME                 = aws_dynamodb_table.goals.id
    BROADCASTS_TABLE_NAME            = aws_dynamodb_table.broadcasts.id
    REQUEST_LOG_TABLE_NAME           = aws_dynamodb_table.request_log.id
    CRON_RUNS_TABLE_NAME             = aws_dynamodb_table.cron_runs.id
    NOTIFICATION_LOG_TABLE_NAME      = aws_dynamodb_table.notification_log.id
    NOTIFICATIONS_TABLE_NAME         = aws_dynamodb_table.notifications.id
    NOTIFICATION_PENDING_TABLE_NAME  = aws_dynamodb_table.notification_pending.id
    VISITS_TABLE_NAME                = aws_dynamodb_table.visits.id
    ADMIN_EMAIL                      = var.admin_email
    NOTIFICATIONS_SEND_FUNCTION_NAME = "${var.app_name}-notifications-send"
    BROADCAST_FANOUT_FUNCTION_NAME   = "${var.app_name}-notifications-broadcast-fanout"
    APNS_AUTH_KEY_PARAM              = aws_ssm_parameter.apns_auth_key.name
    APNS_KEY_ID_PARAM                = aws_ssm_parameter.apns_key_id.name
    APNS_TEAM_ID_PARAM               = aws_ssm_parameter.apns_team_id.name
    APNS_BUNDLE_ID_PARAM             = aws_ssm_parameter.apns_bundle_id.name
    AWS_ACCOUNT_ID                   = data.aws_caller_identity.web_app_account.account_id
    FROM_EMAIL                       = var.from_email
  }

  # API Gateway allowed headers
  api_allow_headers = [
    "Authorization",
    "Content-Type",
    "X-Amz-Date",
    "X-Amz-Security-Token",
    "X-Api-Key",
    "Origin",
    "Accept",
    "Access-Control-Allow-Origin",
    "Accept-Language"
  ]
}
