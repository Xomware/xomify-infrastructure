
output "github_actions_frontend_role_arn" {
  description = "Role the xomify-frontend deploy workflow assumes via OIDC"
  value       = aws_iam_role.github_actions["frontend"].arn
}

output "github_actions_backend_role_arn" {
  description = "Role the xomify-backend deploy workflow assumes via OIDC"
  value       = aws_iam_role.github_actions["backend"].arn
}

output "github_actions_ios_role_arn" {
  description = "Role the xomify-ios TestFlight workflow assumes via OIDC"
  value       = aws_iam_role.github_actions["ios"].arn
}
