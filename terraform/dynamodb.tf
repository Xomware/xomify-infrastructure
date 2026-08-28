
########################################
# 1. xomify-users
########################################
resource "aws_dynamodb_table" "users" {
  deletion_protection_enabled = true
  name                        = "${var.app_name}-users"
  billing_mode                = "PAY_PER_REQUEST"
  read_capacity               = 0
  write_capacity              = 0
  hash_key                    = "email"

  server_side_encryption {
    enabled     = true
    kms_key_arn = aws_kms_alias.dynamodb.target_key_arn
  }

  point_in_time_recovery {
    enabled = true
  }

  attribute {
    name = "email"
    type = "S"
  }

  tags = merge(local.standard_tags, tomap({ "name" = "${var.app_name}-users" }))

}
########################################
# 2. xomify-wrapped-history
########################################
resource "aws_dynamodb_table" "wrapped_history" {
  deletion_protection_enabled = true
  name                        = "${var.app_name}-wrapped-history"
  billing_mode                = "PAY_PER_REQUEST"
  read_capacity               = 0
  write_capacity              = 0
  hash_key                    = "email"
  range_key                   = "monthKey"

  server_side_encryption {
    enabled     = true
    kms_key_arn = aws_kms_alias.dynamodb.target_key_arn
  }

  point_in_time_recovery {
    enabled = true
  }

  attribute {
    name = "email"
    type = "S"
  }
  attribute {
    name = "monthKey"
    type = "S"
  }

  tags = merge(local.standard_tags, tomap({ "name" = "${var.app_name}-wrapped-history" }))

}
########################################
# 3. xomify-release-radar-history
########################################
resource "aws_dynamodb_table" "release_radar_history" {
  deletion_protection_enabled = true
  name                        = "${var.app_name}-release-radar-history"
  billing_mode                = "PAY_PER_REQUEST"
  read_capacity               = 0
  write_capacity              = 0
  hash_key                    = "email"
  range_key                   = "weekKey"

  server_side_encryption {
    enabled     = true
    kms_key_arn = aws_kms_alias.dynamodb.target_key_arn
  }

  point_in_time_recovery {
    enabled = true
  }

  attribute {
    name = "email"
    type = "S"
  }
  attribute {
    name = "weekKey"
    type = "S"
  }

  tags = merge(local.standard_tags, tomap({ "name" = "${var.app_name}-release-radar-history" }))

}

########################################
# 4. xomify-friendships
########################################
resource "aws_dynamodb_table" "friendships" {
  deletion_protection_enabled = true
  name                        = "${var.app_name}-friendships"
  billing_mode                = "PAY_PER_REQUEST"
  read_capacity               = 0
  write_capacity              = 0
  hash_key                    = "email"
  range_key                   = "friendEmail"

  server_side_encryption {
    enabled     = true
    kms_key_arn = aws_kms_alias.dynamodb.target_key_arn
  }

  point_in_time_recovery {
    enabled = true
  }
  attribute {
    name = "email"
    type = "S"
  }

  attribute {
    name = "friendEmail"
    type = "S"
  }

  tags = merge(local.standard_tags, tomap({ "name" = "${var.app_name}-friendships" }))
}

########################################
# 5. xomify-groups
########################################
resource "aws_dynamodb_table" "groups" {
  deletion_protection_enabled = true
  name                        = "${var.app_name}-groups"
  billing_mode                = "PAY_PER_REQUEST"
  read_capacity               = 0
  write_capacity              = 0
  hash_key                    = "groupId"

  server_side_encryption {
    enabled     = true
    kms_key_arn = aws_kms_alias.dynamodb.target_key_arn
  }

  point_in_time_recovery {
    enabled = true
  }

  attribute {
    name = "groupId"
    type = "S"
  }

  tags = merge(local.standard_tags, tomap({ "name" = "${var.app_name}-groups" }))
}

########################################
# 6. xomify-group-members
########################################
resource "aws_dynamodb_table" "group_members" {
  deletion_protection_enabled = true
  name                        = "${var.app_name}-group-members"
  billing_mode                = "PAY_PER_REQUEST"
  read_capacity               = 0
  write_capacity              = 0
  hash_key                    = "email"
  range_key                   = "groupId"

  server_side_encryption {
    enabled     = true
    kms_key_arn = aws_kms_alias.dynamodb.target_key_arn
  }

  point_in_time_recovery {
    enabled = true
  }

  attribute {
    name = "email"
    type = "S"
  }
  attribute {
    name = "groupId"
    type = "S"
  }

  # GSI: Lookup members by groupId
  global_secondary_index {
    name            = "groupId-email-index"
    hash_key        = "groupId"
    range_key       = "email"
    projection_type = "ALL"
  }

  tags = merge(local.standard_tags, tomap({ "name" = "${var.app_name}-groups-members" }))
}

########################################
# 7. xomify-group-tracks
########################################
resource "aws_dynamodb_table" "group_tracks" {
  deletion_protection_enabled = true
  name                        = "${var.app_name}-group-tracks"
  billing_mode                = "PAY_PER_REQUEST"
  read_capacity               = 0
  write_capacity              = 0
  hash_key                    = "groupId"
  range_key                   = "trackIdTimestamp"

  server_side_encryption {
    enabled     = true
    kms_key_arn = aws_kms_alias.dynamodb.target_key_arn
  }

  point_in_time_recovery {
    enabled = true
  }

  attribute {
    name = "groupId"
    type = "S"
  }

  attribute {
    name = "trackIdTimestamp"
    type = "S"
  }

  # trackId_timestamp format: trackId#timestamp

  tags = merge(local.standard_tags, tomap({ "name" = "${var.app_name}-group-tracks" }))
}

########################################
# 8. xomify-track-ratings
########################################
resource "aws_dynamodb_table" "track_ratings" {
  deletion_protection_enabled = true
  name                        = "${var.app_name}-track-ratings"
  billing_mode                = "PAY_PER_REQUEST"
  read_capacity               = 0
  write_capacity              = 0
  hash_key                    = "email"
  range_key                   = "trackId"

  server_side_encryption {
    enabled     = true
    kms_key_arn = aws_kms_alias.dynamodb.target_key_arn
  }

  point_in_time_recovery {
    enabled = true
  }

  attribute {
    name = "email"
    type = "S"
  }

  attribute {
    name = "trackId"
    type = "S"
  }

  tags = merge(local.standard_tags, tomap({ "name" = "${var.app_name}-track-ratings" }))
}

########################################
# 9. xomify-shares
########################################
resource "aws_dynamodb_table" "shares" {
  deletion_protection_enabled = true
  name                        = "${var.app_name}-shares"
  billing_mode                = "PAY_PER_REQUEST"
  read_capacity               = 0
  write_capacity              = 0
  hash_key                    = "shareId"

  server_side_encryption {
    enabled     = true
    kms_key_arn = aws_kms_alias.dynamodb.target_key_arn
  }

  point_in_time_recovery {
    enabled = true
  }

  attribute {
    name = "shareId"
    type = "S"
  }

  attribute {
    name = "email"
    type = "S"
  }

  attribute {
    name = "createdAt"
    type = "S"
  }

  # GSI: Lookup shares by author email, ordered by createdAt
  global_secondary_index {
    name            = "email-createdAt-index"
    hash_key        = "email"
    range_key       = "createdAt"
    projection_type = "ALL"
  }

  tags = merge(local.standard_tags, tomap({ "name" = "${var.app_name}-shares" }))
}

########################################
# 10. xomify-share-interactions
########################################
resource "aws_dynamodb_table" "share_interactions" {
  deletion_protection_enabled = true
  name                        = "${var.app_name}-share-interactions"
  billing_mode                = "PAY_PER_REQUEST"
  read_capacity               = 0
  write_capacity              = 0
  hash_key                    = "shareId"
  range_key                   = "email"

  server_side_encryption {
    enabled     = true
    kms_key_arn = aws_kms_alias.dynamodb.target_key_arn
  }

  point_in_time_recovery {
    enabled = true
  }

  attribute {
    name = "shareId"
    type = "S"
  }

  attribute {
    name = "email"
    type = "S"
  }

  tags = merge(local.standard_tags, tomap({ "name" = "${var.app_name}-share-interactions" }))
}

########################################
# 10b. xomify-share-listeners
########################################
# Tracks which viewers have listened to which shared track (via Queue / Play
# Now / share creation). Separate from share-interactions because listened
# volume is much higher than queued/rated and the lifecycle is different
# (we may TTL or cap older rows later).
resource "aws_dynamodb_table" "share_listeners" {
  deletion_protection_enabled = true
  name                        = "${var.app_name}-share-listeners"
  billing_mode                = "PAY_PER_REQUEST"
  read_capacity               = 0
  write_capacity              = 0
  hash_key                    = "shareId"
  range_key                   = "email"

  server_side_encryption {
    enabled     = true
    kms_key_arn = aws_kms_alias.dynamodb.target_key_arn
  }

  point_in_time_recovery {
    enabled = true
  }

  attribute {
    name = "shareId"
    type = "S"
  }

  attribute {
    name = "email"
    type = "S"
  }

  tags = merge(local.standard_tags, tomap({ "name" = "${var.app_name}-share-listeners" }))
}

########################################
# 11. xomify-share-comments
########################################
resource "aws_dynamodb_table" "share_comments" {
  deletion_protection_enabled = true
  name                        = "${var.app_name}-share-comments"
  billing_mode                = "PAY_PER_REQUEST"
  read_capacity               = 0
  write_capacity              = 0
  hash_key                    = "shareId"
  range_key                   = "createdAtId"

  server_side_encryption {
    enabled     = true
    kms_key_arn = aws_kms_alias.dynamodb.target_key_arn
  }

  point_in_time_recovery {
    enabled = true
  }

  attribute {
    name = "shareId"
    type = "S"
  }

  attribute {
    name = "createdAtId"
    type = "S"
  }

  tags = merge(local.standard_tags, tomap({ "name" = "${var.app_name}-share-comments" }))
}

########################################
# 12. xomify-share-reactions
########################################
resource "aws_dynamodb_table" "share_reactions" {
  deletion_protection_enabled = true
  name                        = "${var.app_name}-share-reactions"
  billing_mode                = "PAY_PER_REQUEST"
  read_capacity               = 0
  write_capacity              = 0
  hash_key                    = "shareId"
  range_key                   = "emailReaction"

  server_side_encryption {
    enabled     = true
    kms_key_arn = aws_kms_alias.dynamodb.target_key_arn
  }

  point_in_time_recovery {
    enabled = true
  }

  attribute {
    name = "shareId"
    type = "S"
  }

  attribute {
    name = "emailReaction"
    type = "S"
  }

  tags = merge(local.standard_tags, tomap({ "name" = "${var.app_name}-share-reactions" }))
}

########################################
# 13. xomify-invites
########################################
resource "aws_dynamodb_table" "invites" {
  deletion_protection_enabled = true
  name                        = "${var.app_name}-invites"
  billing_mode                = "PAY_PER_REQUEST"
  read_capacity               = 0
  write_capacity              = 0
  hash_key                    = "inviteCode"

  server_side_encryption {
    enabled     = true
    kms_key_arn = aws_kms_alias.dynamodb.target_key_arn
  }

  point_in_time_recovery {
    enabled = true
  }

  attribute {
    name = "inviteCode"
    type = "S"
  }

  tags = merge(local.standard_tags, tomap({ "name" = "${var.app_name}-invites" }))
}

########################################
# 14. xomify-top-items-cache
########################################
resource "aws_dynamodb_table" "top_items_cache" {
  deletion_protection_enabled = true
  name                        = "${var.app_name}-top-items-cache"
  billing_mode                = "PAY_PER_REQUEST"
  read_capacity               = 0
  write_capacity              = 0
  hash_key                    = "email"

  server_side_encryption {
    enabled     = true
    kms_key_arn = aws_kms_alias.dynamodb.target_key_arn
  }

  point_in_time_recovery {
    enabled = true
  }

  attribute {
    name = "email"
    type = "S"
  }

  ttl {
    attribute_name = "ttl"
    enabled        = true
  }

  tags = merge(local.standard_tags, tomap({ "name" = "${var.app_name}-top-items-cache" }))
}

########################################
# 15. xomify-device-tokens
########################################
resource "aws_dynamodb_table" "device_tokens" {
  deletion_protection_enabled = true
  name                        = "${var.app_name}-device-tokens"
  billing_mode                = "PAY_PER_REQUEST"
  read_capacity               = 0
  write_capacity              = 0
  hash_key                    = "email"
  range_key                   = "deviceToken"

  server_side_encryption {
    enabled     = true
    kms_key_arn = aws_kms_alias.dynamodb.target_key_arn
  }

  point_in_time_recovery {
    enabled = true
  }

  attribute {
    name = "email"
    type = "S"
  }

  attribute {
    name = "deviceToken"
    type = "S"
  }

  # MUST match the attribute the application writes.
  #
  # This was "expiresAt" while device_tokens_dynamo.upsert_token has always
  # written "ttl" — a TTL configured on an attribute nothing writes never
  # fires, so device tokens have never expired despite that module's docstring
  # promising a ~180 day prune.
  #
  # Rows carry a `ttl` 180 days in the future, so correcting this only reaps
  # genuinely dormant tokens — which is what the code always intended. A pruned
  # token is also harmless: the next registration re-creates it, and APNs
  # returns 410 for one that is truly dead.
  # MUST match the attribute the application writes.
  #
  # This was "expiresAt" while device_tokens_dynamo.upsert_token has always
  # written "ttl" — a TTL on an attribute nothing writes never fires, so device
  # tokens never expired, despite that module's docstring promising a ~180 day
  # prune.
  #
  # Moving it took two applies: DynamoDB refuses to change the attribute while
  # TTL is active ("TimeToLive is active on a different AttributeName"), so it
  # was disabled first. This is step 2.
  #
  # Safe: rows already carry a `ttl` 180 days out, so only genuinely dormant
  # tokens get reaped — which is what the code always intended. A pruned token
  # is harmless anyway; the next registration re-creates it, and APNs returns
  # 410 for one that is truly dead.
  ttl {
    attribute_name = "ttl"
    enabled        = true
  }

  tags = merge(local.standard_tags, tomap({ "name" = "${var.app_name}-device-tokens" }))
}

########################################
# 16. xomify-user-likes
# Per-user saved tracks pushed from iOS on cold open.
# PK email + SK addedAtTrackId ("<addedAt ISO8601>#<trackId>") gives
# desc-by-recency paginated reads via ScanIndexForward=False.
# GSI email-addedAt-index lets queries sort purely on addedAt without
# needing the trackId tail when the SK isn't useful as a tiebreaker.
########################################
resource "aws_dynamodb_table" "user_likes" {
  deletion_protection_enabled = true
  name                        = "${var.app_name}-user-likes"
  billing_mode                = "PAY_PER_REQUEST"
  read_capacity               = 0
  write_capacity              = 0
  hash_key                    = "email"
  range_key                   = "addedAtTrackId"

  server_side_encryption {
    enabled     = true
    kms_key_arn = aws_kms_alias.dynamodb.target_key_arn
  }

  point_in_time_recovery {
    enabled = true
  }

  attribute {
    name = "email"
    type = "S"
  }

  attribute {
    name = "addedAtTrackId"
    type = "S"
  }

  attribute {
    name = "addedAt"
    type = "S"
  }

  # GSI: query likes by email sorted purely by addedAt
  global_secondary_index {
    name            = "email-addedAt-index"
    hash_key        = "email"
    range_key       = "addedAt"
    projection_type = "ALL"
  }

  tags = merge(local.standard_tags, tomap({ "name" = "${var.app_name}-user-likes" }))
}

########################################
# 17. xomify-favorites
# Single-table year-end favorites lists + rank-change history.
# PK email + SK sk carries multiple row types:
#   LIST#{year}#{listId}  — a ranked list (overall or custom)
#   HIST#{listId}#{ts}#{seq} — append-only rank-change events
#   REMINDER#{year}       — cron idempotency marker
# Query by year via begins_with(sk, "LIST#{year}#"); history via
# begins_with(sk, "HIST#{listId}#"). No GSI needed.
########################################
resource "aws_dynamodb_table" "favorites" {
  deletion_protection_enabled = true
  name                        = "${var.app_name}-favorites"
  billing_mode                = "PAY_PER_REQUEST"
  read_capacity               = 0
  write_capacity              = 0
  hash_key                    = "email"
  range_key                   = "sk"

  server_side_encryption {
    enabled     = true
    kms_key_arn = aws_kms_alias.dynamodb.target_key_arn
  }

  point_in_time_recovery {
    enabled = true
  }

  attribute {
    name = "email"
    type = "S"
  }

  attribute {
    name = "sk"
    type = "S"
  }

  tags = merge(local.standard_tags, tomap({ "name" = "${var.app_name}-favorites" }))
}

########################################
# 18. xomify-broadcasts
# Small admin-authored broadcast/announcement table. "active" is computed
# (activeUntil null or in the future) via scan+filter given tiny volume.
# Optional TTL on `ttl` (epoch) reaps expired rows when activeUntil is set.
########################################
resource "aws_dynamodb_table" "broadcasts" {
  deletion_protection_enabled = true
  name                        = "${var.app_name}-broadcasts"
  billing_mode                = "PAY_PER_REQUEST"
  read_capacity               = 0
  write_capacity              = 0
  hash_key                    = "broadcastId"

  server_side_encryption {
    enabled     = true
    kms_key_arn = aws_kms_alias.dynamodb.target_key_arn
  }

  point_in_time_recovery {
    enabled = true
  }

  attribute {
    name = "broadcastId"
    type = "S"
  }

  ttl {
    attribute_name = "ttl"
    enabled        = true
  }

  tags = merge(local.standard_tags, tomap({ "name" = "${var.app_name}-broadcasts" }))
}

########################################
# 19. xomify-request-log  (admin Health)
# Per-request instrumentation written fail-open by the shared handle_errors
# hook. PK day ("YYYY-MM-DD") spreads writes across day partitions; SK tsId
# ("<iso ts>#<rand8>") sorts by time and de-dupes. TTL ~14d reaps old rows.
# Health reads Query each day partition in the window with tsId >= cutoff.
########################################
resource "aws_dynamodb_table" "request_log" {
  deletion_protection_enabled = true
  name                        = "${var.app_name}-request-log"
  billing_mode                = "PAY_PER_REQUEST"
  read_capacity               = 0
  write_capacity              = 0
  hash_key                    = "day"
  range_key                   = "tsId"

  server_side_encryption {
    enabled     = true
    kms_key_arn = aws_kms_alias.dynamodb.target_key_arn
  }

  point_in_time_recovery {
    enabled = true
  }

  attribute {
    name = "day"
    type = "S"
  }

  attribute {
    name = "tsId"
    type = "S"
  }

  ttl {
    attribute_name = "ttl"
    enabled        = true
  }

  tags = merge(local.standard_tags, tomap({ "name" = "${var.app_name}-request-log" }))
}

########################################
# 20. xomify-cron-runs  (admin Crons)
# One row per cron execution, written by record_cron_run. PK cronName +
# SK startedAt (ISO) gives newest-first Query per cron. Admin Crons scans
# the (small) table and groups by cronName.
########################################
resource "aws_dynamodb_table" "cron_runs" {
  deletion_protection_enabled = true
  name                        = "${var.app_name}-cron-runs"
  billing_mode                = "PAY_PER_REQUEST"
  read_capacity               = 0
  write_capacity              = 0
  hash_key                    = "cronName"
  range_key                   = "startedAt"

  server_side_encryption {
    enabled     = true
    kms_key_arn = aws_kms_alias.dynamodb.target_key_arn
  }

  point_in_time_recovery {
    enabled = true
  }

  attribute {
    name = "cronName"
    type = "S"
  }

  attribute {
    name = "startedAt"
    type = "S"
  }

  tags = merge(local.standard_tags, tomap({ "name" = "${var.app_name}-cron-runs" }))
}

########################################
# 21. xomify-notification-log  (admin Notifications)
# One row per outbound email (SES) / push (APNs) send, written fail-open by
# the send helpers. PK day + SK tsId ("<iso ts>#<rand8>"). Admin Notifications
# scans and sorts desc, capped by ?limit=.
########################################
resource "aws_dynamodb_table" "notification_log" {
  deletion_protection_enabled = true
  name                        = "${var.app_name}-notification-log"
  billing_mode                = "PAY_PER_REQUEST"
  read_capacity               = 0
  write_capacity              = 0
  hash_key                    = "day"
  range_key                   = "tsId"

  server_side_encryption {
    enabled     = true
    kms_key_arn = aws_kms_alias.dynamodb.target_key_arn
  }

  point_in_time_recovery {
    enabled = true
  }

  attribute {
    name = "day"
    type = "S"
  }

  attribute {
    name = "tsId"
    type = "S"
  }

  tags = merge(local.standard_tags, tomap({ "name" = "${var.app_name}-notification-log" }))
}

########################################
# 22. xomify-visits  (admin Users page-visit history)
# Lightweight per-user visit events posted from the frontend on route change.
# PK email + SK ts ("<iso ts>#<rand8>") gives a newest-first Query per user.
# TTL ~30d reaps old rows.
########################################
resource "aws_dynamodb_table" "visits" {
  deletion_protection_enabled = true
  name                        = "${var.app_name}-visits"
  billing_mode                = "PAY_PER_REQUEST"
  read_capacity               = 0
  write_capacity              = 0
  hash_key                    = "email"
  range_key                   = "ts"

  server_side_encryption {
    enabled     = true
    kms_key_arn = aws_kms_alias.dynamodb.target_key_arn
  }

  point_in_time_recovery {
    enabled = true
  }

  attribute {
    name = "email"
    type = "S"
  }

  attribute {
    name = "ts"
    type = "S"
  }

  ttl {
    attribute_name = "ttl"
    enabled        = true
  }

  tags = merge(local.standard_tags, tomap({ "name" = "${var.app_name}-visits" }))
}

# ============================================================================
# Notifications inbox (relaunch epic, B3)
# ============================================================================
# Per-user notification feed with read state. Deliberately NOT the same table
# as `notification_log`: that one is PK `day` and answers "what did we send
# yesterday?" for the admin view. This one is PK `email`, queried newest-first
# for one user, with mutable read state.
#
# The sort key is "<iso8601>#<rand8>". ISO8601 sorts chronologically and
# lexicographically at once, so ScanIndexForward=false is newest-first with no
# extra index, and paging is a plain ExclusiveStartKey.
resource "aws_dynamodb_table" "notifications" {
  name           = "${var.app_name}-notifications"
  billing_mode   = "PAY_PER_REQUEST"
  read_capacity  = 0
  write_capacity = 0

  # Every other stateful table here carries this; these two were added later
  # and missed it. A user's notification feed and its read state have no other
  # source, and PITR restores a table rather than surviving one being deleted.
  deletion_protection_enabled = true
  hash_key                    = "email"
  range_key                   = "tsId"

  server_side_encryption {
    enabled     = true
    kms_key_arn = aws_kms_alias.dynamodb.target_key_arn
  }

  point_in_time_recovery {
    enabled = true
  }

  attribute {
    name = "email"
    type = "S"
  }

  attribute {
    name = "tsId"
    type = "S"
  }

  # MUST match the attribute the application actually writes
  # (notifications_dynamo.put_notification writes `ttl`). A TTL configured on
  # an attribute nobody writes is a TTL that never fires — see the note on
  # `device_tokens` below.
  ttl {
    attribute_name = "ttl"
    enabled        = true
  }

  tags = merge(local.standard_tags, tomap({ "name" = "${var.app_name}-notifications" }))
}

# ============================================================================
# Notification coalescing buffer (relaunch epic, B1)
# ============================================================================
# Holds the first of a sibling pair (share_listened / share_rated) for up to
# ten minutes so the two can go out as one push. Rows are short-lived by
# design; the 5-minute sweeper cron drains anything whose window lapsed, and
# TTL is only a backstop for rows the sweeper never got to.
resource "aws_dynamodb_table" "notification_pending" {
  name           = "${var.app_name}-notification-pending"
  billing_mode   = "PAY_PER_REQUEST"
  read_capacity  = 0
  write_capacity = 0

  # The rows here are transient, which is an argument about the data and not
  # about the table: losing it drops ten minutes of pending pushes and then
  # breaks every coalesced notification until an apply puts it back.
  deletion_protection_enabled = true
  hash_key                    = "coalesceKey"

  server_side_encryption {
    enabled     = true
    kms_key_arn = aws_kms_alias.dynamodb.target_key_arn
  }

  # No PITR: every row here is transient and reconstructible. Backing up a
  # ten-minute buffer is paying to protect nothing.
  point_in_time_recovery {
    enabled = false
  }

  attribute {
    name = "coalesceKey"
    type = "S"
  }

  ttl {
    attribute_name = "ttl"
    enabled        = true
  }

  tags = merge(local.standard_tags, tomap({ "name" = "${var.app_name}-notification-pending" }))
}

# ============================================================================

