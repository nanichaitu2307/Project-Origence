# FIX: Added variable description and type definition
# to improve readability and validation.

variable "environment" {
  description = "Deployment environment"
  type        = string
  default     = "prod"
}

# FIX: Added variable description and type definition
# to improve readability and validation.

variable "location" {
  description = "Azure region for deployment"
  type        = string
  default     = "West US"
}

# SECURITY: Removed hardcoded database password.
# Value should be supplied through tfvars, pipeline variables,
# or Azure Key Vault.

variable "sql_admin_password" {
  description = "SQL administrator password"
  type        = string
  sensitive   = true
}

# SECURITY: Removed hardcoded API key.
# Value should be supplied through tfvars, pipeline variables,
# or Azure Key Vault.

variable "api_key" {
  description = "Application API key"
  type        = string
  sensitive   = true
}

# FIX: Added variable description and type definition
# to improve readability and validation.

variable "app_name" {
  description = "Application name"
  type        = string
}

# FIX: Avoid using latest image tag by default.
# Pipeline should provide a unique build tag.

variable "image_tag" {
  description = "Container image tag"
  type        = string
}

# SECURITY: Removed hardcoded Datadog API key.
# Value should be supplied through tfvars, pipeline variables,
# or Azure Key Vault.

variable "datadog_api_key" {
  description = "Datadog API key"
  type        = string
  sensitive   = true
}