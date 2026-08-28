variable "app_name" {
  description = "The name for the application."
  type        = string
  default     = "xomify"
}

variable "client_id" {
  description = "Spotify Web API Client ID"
  type        = string
  sensitive   = true
}

variable "client_secret" {
  description = "Spotify Web API Client Secret"
  type        = string
  sensitive   = true
}

variable "api_access_token" {
  description = "API access token"
  type        = string
  sensitive   = true
}

variable "api_secret_key" {
  description = "API Secret Key for FE / BE to use"
  type        = string
  sensitive   = true
}

variable "domain_suffix" {
  description = "Suffix for the domain of the app."
  type        = string
  default     = ".xomware.com"
}

variable "aws_region" {
  description = "AWS region for resources"
  type        = string
  default     = "us-east-1"
}

# CloudFront Variables
variable "cloudfront_origin_path" {
  description = "Optional element for cloudfront distribution that causes CloudFront to request your content from a directory in your Amazon S3 bucket."
  type        = string
  default     = ""
}

variable "us_canada_only" {
  description = "If a georestriction should be placed on the distribution to only provide access to the US and Canada"
  type        = bool
  default     = true
}

variable "custom_error_response_page_path" {
  description = "Custom error response page path for SPA routing."
  type        = string
  default     = "/index.html"
}

variable "retain_on_delete" {
  description = "Disables the distribution instead of deleting it when destroying the resource through Terraform."
  type        = bool
  default     = false
}

variable "minimum_tls_version" {
  description = "Minimum TLS version for CloudFront"
  type        = string
  default     = "TLSv1.2_2018"
}

variable "enable_cloudfront_cache" {
  description = "This variable controls the cloudfront cache. Setting this to false will set the default_ttl and max_ttl values to zero"
  type        = bool
  default     = true
}

# Lambda Variables
variable "lambda_runtime" {
  description = "Runtime for Lambda functions"
  type        = string
  default     = "python3.12"
}

variable "lambda_trace_mode" {
  description = "X-Ray tracing mode for Lambda"
  type        = string
  default     = "Active"
}

variable "lambda_memory_size" {
  description = "Memory size for Lambda functions in MB"
  type        = number
  default     = 1024
}

variable "lambda_timeout" {
  description = "Timeout for Lambda functions in seconds"
  type        = number
  default     = 900
}

# Email Service
variable "from_email" {
  description = "Email address to send from"
  type        = string
  default     = "noreply@xomify.xomware.com"
}

# Admin
variable "admin_email" {
  description = "Email address granted admin privileges (broadcast management). Compared case-insensitively against the caller's JWT email."
  type        = string
  default     = "dominickj.giordano@gmail.com"
}

# API Gateway
variable "api_stage_name" {
  description = "API Gateway deployment stage name"
  type        = string
  default     = "dev"
}

variable "cors_allowed_origins" {
  description = "Comma-delimited allowed CORS origins for the API. First entry is the default Access-Control-Allow-Origin; additional entries are echoed back via startsWith matching by the api module."
  type        = string
  default     = "https://xomify.xomware.com,https://xomware.com,https://www.xomware.com"
}

# Route53
variable "route53_zone_name" {
  description = "Route53 hosted zone name for DNS records"
  type        = string
  default     = "xomware.com"
}

# Tags
variable "environment" {
  description = "Deployment environment"
  type        = string
  default     = "production"
}

variable "owner" {
  description = "Owner of the infrastructure"
  type        = string
  default     = "domgiordano"
}

# Authorizer-specific settings
variable "authorizer_memory_size" {
  description = "Memory size for authorizer Lambda in MB"
  type        = number
  default     = 256
}

variable "authorizer_timeout" {
  description = "Timeout for authorizer Lambda in seconds"
  type        = number
  default     = 30
}

# APNs (Apple Push Notification service)
# Defaults intentionally empty so `terraform apply` succeeds before secrets are populated.
# SSM SecureString params pick up real values on the next apply once TF_VAR_apns_* are set.
variable "apns_signing_key_p8" {
  description = "Contents of the APNs .p8 signing key (full PEM including BEGIN/END lines). Set via TF_VAR_apns_signing_key_p8 or a gitignored terraform.tfvars — never commit."
  type        = string
  sensitive   = true
  default     = ""
}

variable "apns_key_id" {
  description = "APNs auth key ID (matches the AuthKey_<KEY_ID>.p8 filename)."
  type        = string
  sensitive   = true
  default     = ""
}

variable "apns_team_id" {
  description = "Apple Developer Team ID used as the iss claim when signing APNs provider tokens."
  type        = string
  sensitive   = true
  default     = ""
}

variable "apns_bundle_id" {
  description = "iOS app bundle identifier used as the apns-topic header."
  type        = string
  default     = "com.Xomware.Xomify"
}


variable "github_frontend_repo" {
  description = "owner/repo whose GitHub Actions may assume the frontend deploy role"
  type        = string
  default     = "Xomware/xomify-frontend"
}

variable "github_backend_repo" {
  description = "owner/repo whose GitHub Actions may assume the backend deploy role"
  type        = string
  default     = "Xomware/xomify-backend"
}

variable "github_ios_repo" {
  description = "owner/repo whose GitHub Actions may assume the iOS build role"
  type        = string
  default     = "Xomware/xomify-ios"
}

variable "github_infrastructure_repo" {
  description = "owner/repo of this infrastructure repository"
  type        = string
  default     = "Xomware/xomify-infrastructure"
}

variable "github_infrastructure_subjects" {
  description = "OIDC subject prefixes for this infrastructure repository"
  type        = list(string)
  default     = ["repo:Xomware/xomify-infrastructure"]
}

variable "default_branch" {
  description = "Branch a push to which is allowed to run terraform apply"
  type        = string
  default     = "master"
}
