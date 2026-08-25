# Plan: notification-infra

**Epic**: [xomify-relaunch](https://github.com/Xomware/xomify-frontend/blob/master/docs/features/xomify-relaunch/PLAN.md)
**Sub-feature ID**: B6 (`notification-infra`)
**Track**: B — Notifications Platform
**Status**: Done (validated, NOT applied)
**Created**: 2026-08-24
**Last updated**: 2026-08-24
**Scope size**: TBD — run `/plan notification-infra` to size
**Repo(s) touched**: `xomify-infrastructure`
**Branch**: `feature/notification-infra`
**Wave**: 4
**Depends on**: `B3`, `B5`

---

## Summary

Terraform for the inbox table, the new crons, and the widened invoke permissions.

## Approach

xomify-notifications table + API Gateway routes for B3. Lambda + IAM + daily schedule for cron_rate_reminder. A SECOND 5-minute schedule for the B1 coalesce sweeper — the 10-minute window cannot ride the daily cron. IAM for the new notifications_send invokers from B4. MUST APPLY BEFORE B3/B5 lambdas can run in prod.

## Affected Files / Components

- `terraform/lambdas_notifications.tf`
- `terraform/locals.tf`

## Implementation Steps

_Stub — not yet planned. Run `/plan notification-infra` to expand this into ordered, checkable steps._

- [ ] TBD

## Acceptance

_Stub — define with `/plan notification-infra`._

---

## Epic context

Locked decisions live in the epic plan and must not be re-litigated here. See
`https://github.com/Xomware/xomify-frontend/blob/master/docs/features/xomify-relaunch/PLAN.md` — decisions table, rows 1-11.

---

## Outcome

`terraform validate` → **Success** (the two warnings are pre-existing S3 lifecycle ones).
**Not applied** — deployment goes through PR merge, per the org CI/CD convention.

| Change | File |
|--------|------|
| `xomify-notifications` table (PK `email`, SK `tsId`, TTL `ttl`, PITR on) | `dynamodb.tf` |
| `xomify-notification-pending` table (PK `coalesceKey`, TTL `ttl`, PITR off) | `dynamodb.tf` |
| `NOTIFICATIONS_TABLE_NAME`, `NOTIFICATION_PENDING_TABLE_NAME` | `locals.tf` |
| `feed` (GET), `read` (POST), `unread-count` (GET) lambdas + routes | `lambdas_notifications.tf` |
| `rate-reminder` cron — daily, `cron(0 17 * * ? *)` | `lambdas_cron.tf` |
| `notification-sweeper` cron — `rate(5 minutes)` | `lambdas_cron.tf` |

### Already covered, verified rather than assumed

- **IAM DynamoDB access.** `lambda_role_policy` scopes to `table/${var.app_name}*`, so both
  new tables are in scope with no policy change.
- **IAM lambda invoke.** `lambda_role_policy` grants `lambda:InvokeFunction` on
  `function:${var.app_name}*`, so B4's request-handler producers can reach
  `notifications-send`. Worth checking rather than assuming — without it every producer
  would fail open and silently send nothing.
- **API Gateway routes.** `notifications_endpoints` is derived from
  `local.notifications_lambdas`, so the three new entries wire themselves.

### Decisions

- **PITR off on `notification_pending`.** Every row is transient and reconstructible;
  backing up a ten-minute buffer is paying to protect nothing.
- **The sweeper gets `rate(5 minutes)`, not the daily slot.** The coalesce window is ten
  minutes — a daily sweep would hold a lone "Sam listened to your song" for up to 24 hours,
  which is worse than never sending it.
- **TTL attribute is `ttl`**, matching what the application actually writes. See below for
  why that is worth stating explicitly.

---

## ⚠️ Pre-existing bug found (NOT fixed here)

`aws_dynamodb_table.device_tokens` sets:

```hcl
ttl {
  attribute_name = "expiresAt"
  enabled        = true
}
```

but `device_tokens_dynamo.upsert_token` writes the attribute **`ttl`**, not `expiresAt`
(`"#ttl": "ttl"`). The TTL is configured on an attribute nothing writes, so **device
tokens have never expired** — the module docstring's "DynamoDB TTL auto-prunes dormant
tokens after ~180 days" has never once fired.

Left alone deliberately. Correcting it — either flipping the Terraform to `ttl` or writing
`expiresAt` from the app — makes every existing row with a past `ttl` immediately eligible
for deletion. That is almost certainly the intent, but it is a production data change and
belongs to its own decision, not a side effect of adding two tables.

**Recommendation**: change the Terraform to `attribute_name = "ttl"`. Rows with a future
`ttl` (180 days out) are unaffected; only genuinely dormant tokens get reaped, which is
what the code always meant to do.
